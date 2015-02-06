require 'twitter_ebooks'
require 'tempfile'
require 'dotenv'
require 'rest-client'

SETTINGS = Dotenv.load.merge(ENV)

class MyBot < Ebooks::Bot
  attr_accessor 'gb_api_key', 'gb_api', 'gb_params'
  attr_reader 'map_names'
  attr_reader 'title_hashtags', 'interjections', 'solo_activities', 'sins'
  attr_reader 'memes'

  def configure
    # Consumer details come from registering an app at https://dev.twitter.com/
    # Once you have consumer details, use "ebooks auth" for new access tokens

    self.consumer_key = SETTINGS['CONSUMER_KEY'] # Your app consumer key
    self.consumer_secret = SETTINGS['CONSUMER_SECRET'] # Your app consumer secret
    self.gb_api_key = SETTINGS['GIANTBOMB_API_KEY']
    self.gb_api = RestClient::Resource.new("http://www.giantbomb.com/api")
    self.gb_params = {:api_key => gb_api_key, :format => :json, :field_list => 'name'}

    # Bespoke, artisinal content:
    @title_hashtags = ["#NameYourJunkAfterAGame", "#DescribeYourSexLifeWithAGame"]
    @interjections = ["lol", "ayyyy lmao", "wtf right?!", "tho", "lmfao", "lmaoooooo", "iM DyING", "*SCREAMING*", "#TRUTH", "#LIFE", "#blessed"]
    @sins = ["romanced CHAR", "slept with CHAR", "had carnal relations with CHAR", "left CHAR to die", "never cared about CHAR", "cried irl over CHAR", "RPed as CHAR", "LARPed as CHAR", "shipped myself with CHAR", "a shrine to CHAR", "coveted my neighbor's CHAR", "taken CHAR's name in vain", "not one fuck to give about CHAR", "known CHAR...biblically."]
    @solo_activities = ["smoked weed", "got drunk", "took you to prom", "got pregnant", "took shrooms", "tripped balls", "went to ur school", "did let's plays", "proposed to you", "were gay", "were gay as hell"]
    @memes = [
      {label: 'title_hashgags', action: :tweet, gen: proc {
        "#{title_hashtags.sample} #{get_game_title}"
      }},
      {label: 'character_confessions', action: :tweet, gen: proc {
        character = get_character_name
        sin = sins.sample.gsub(/CHAR/, character)
        "Forgive me father, for I have #{sin} #GameConfessions"
      }},
      {label: 'dad_games', action: :tweet, gen: proc {
        dad_query = "dead,deadly,bad,badly,sad,rad,radical"
        dad_regex = /dead|bad|rad|sad/i
        "#{random_from_search_result('search/', {:query=>dad_query, :resources=>"game"}).first[:name].gsub(dad_regex, "Dad")} #DadGames"
      }},
      {label: 'evo', action: :tweet, gen: proc {
        "#{get_game_title} confirmed for evo #{interjections.sample}"
      }},
      {label: 'streets_sheets', action: :tweet, gen: proc {
        "#{get_character_name} in the streets, #{get_character_name} in the sheets."
      }},
      {label: 'character_whatif', action: :tweet, gen: proc {
        "what if #{get_character_name} #{solo_activities.sample} #{interjections.sample}"
      }},
      {label: 'title_rt_or_fav', action: :tweet, gen: proc {
        "#{title_hashtags.sample}\nRT if #{get_game_title}\nFav if #{get_game_title}"
      }},
      {label: 'character_otp', action: :tweet, gen: proc {
        "#{get_character_name} x #{get_character_name}: my otp"
      }},
      {label: 'dream_game', action: :tweet, gen: proc {
        "my dream game is #{get_game_title} but with #{get_character_name} in it #{interjections.sample}"
      }},
      {label: 'year_of_character', action: :tweet, gen: proc {
        "#YearOf#{get_character_name.gsub(/[^A-z0-9]/,'')} #{interjections.sample}"
      }},
      {label: 'netflix', action: :tweet, gen: proc {
        "when will #Netflix make a #{get_game_title} show #{interjections.sample}"
      }},
      {label: 'bae_games', action: :tweet, gen: proc {
        title = random_from_search_result('search/', {:query=>"way,lay,slay,pay,play,sway,bay,say,day,may", :resources=>"game"}).first[:name]
        gag_title = title.downcase.gsub(/[pwlbdsm]+aye?(\S*)/, 'bae\1')
        if title.downcase != gag_title
          "#{title}?\nMore like #{gag_title}, amirite?"
        else
          "#{title}?\n More like...I got nothing, but it sucks."
        end
      }},
      {label: 'twitpic_yourself', action: :pictweet, gen: proc {
        img_url = get_character_image
        img_type = File.extname(img_url)[1..-1]
        age = (13..24).to_a.sample
        Tempfile.open("tmp_pic") do |f|
          f.write(RestClient.get(img_url))
          ["#TwitPicYourselfAt#{age}", f.path, {:type=>img_type}]
        end
      }},
      {label: 'game_crushes', action: :tweet, gen: proc {
        img_urls = []
        4.times {img_urls.push get_character_image}

        media_ids = img_urls.map do |img_url|
          Tempfile.open("multi_img") do |f|
            f.write(RestClient.get(img_url))
            twitter.upload(File.new(f.path))
          end
        end

        ["#FourGameCrushes #{interjections.sample}", {:media_ids=>media_ids.join(',')}]
      }}
    ]
    # Users to block instead of interacting with
    self.blacklist = ['tnietzschequote']

    # Range in seconds to randomize delay when bot.delay is called
    self.delay_range = 1..6

    @map_names = Proc.new do |res|
      if res.nil?
        return nil
      elsif res.is_a? String
        res = JSON.parse(res, :symbolize_names=>true)
      end
      res[:results].map {|el| el[:name]}
    end
  end

  def search_game_titles(query, limit=1)
    params = {:limit => limit}
  end

  def random_from_search_result(path='search/', params)
    params = gb_params.merge({:limit=>1}).merge(params)
    res = JSON.parse(gb_api[path].get(:params => params), :symbolize_names=>true)
    total = res[:number_of_total_results]
    if total < 1
      nil
    # elsif res[:error] != "OK"
    #   log "WARN: #{res[:error]}"
    #   nil
    else
      offset = rand(total - params[:limit])
      params[:page] = offset
      # params = params.merge({:offset => offset})
      res = gb_api[path].get(:params => params)
      res = JSON.parse(res, :symbolize_names=>true)
      res[:results]
    end
  end

  def get_game_titles(limit=25)
    params = {:limit => limit, :offset => rand(44550 - limit)}
    params = gb_params.merge(params)
    gb_api['games/'].get(:params => params, &map_names)
  end

  def get_game_title
    get_game_titles(1).first
  end

  def get_character_names(limit=2)
    params = {:limit => limit, :offset => rand(30200 - limit)}
    params = gb_params.merge(params)
    gb_api['characters/'].get(:params => params, &map_names)
  end

  def get_character_name
    get_character_names(1).first
  end

  def get_character_images(limit=2)
    params = gb_params.merge({:limit=>limit, :field_list=>'name,image', :offset=>rand(30200)})
    # TODO: This fails very ungracefully when an image isn't available!
    JSON.parse(gb_api['characters/'].get(:params => params), :symbolize_names=>true)[:results].map {|c| c[:image][:super_url]}
  end

  def get_character_image
    get_character_images(1).first
  end

  def make_meme
    meme = @memes.sample
    action = method(meme[:action])
    action.call(*meme[:gen].call)
  end

  def on_startup
    make_meme
    scheduler.every '48m' do # Tweet something every 48 minutes
      make_meme
    end
  end

  def on_message(dm)
    # Reply to a DM
    # reply(dm, "secret secrets")
  end

  def on_follow(user)
    # Follow a user back
    # follow(user.screen_name)
  end

  def on_mention(tweet)
    # Reply to a mention
    # reply(tweet, "oh hullo")
  end

  def on_timeline(tweet)
    # Reply to a tweet in the bot's timeline
    # reply(tweet, "nice tweet")
  end

  def on_favorite(user, tweet)
    # Follow user who just favorited bot's tweet
    # follow(user.screen_name)
  end
end

# Make a MyBot and attach it to an account
MyBot.new("GamesMemes") do |bot|
  bot.access_token = SETTINGS['ACCESS_TOKEN'] # Token connecting the app to this account
  bot.access_token_secret = SETTINGS['ACCESS_TOKEN_SECRET'] # Secret connecting the app to this account
end
