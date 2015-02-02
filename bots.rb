require 'twitter_ebooks'
require 'dotenv'
require 'rest-client'

SETTINGS = Dotenv.load.merge(ENV)

class MyBot < Ebooks::Bot
  attr_accessor 'gb_api_key', 'gb_api', 'gb_params'
  attr_reader 'map_names'
  attr_reader 'title_hashtags', 'interjections', 'solo_activities', 'sins'

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

  def make_meme
    case rand(1102)
    when 0...100
      "#{title_hashtags.sample} #{get_game_title}"
    when 100...200
      character = get_character_name
      sin = sins.sample.gsub(/CHAR/, character)
      "Forgive me father, for I have #{sin} #GameConfessions"
    when 200...300
      "#{random_from_search_result('search/', {:query=>"dead,deadly,bad,badly", :resources=>"game"}).first[:name].gsub(/dead|bad/i, "Dad")} #DadGames"
    when 300...400
      "#{get_game_title} confirmed for evo #{interjections.sample}"
    when 400...500
      "#{get_character_name} in the streets, #{get_character_name} in the sheets."
    when 500...600
      "what if #{get_character_name} #{solo_activities.sample} #{interjections.sample}"
    when 600...700
      "#{title_hashtags.sample}\nRT if #{get_game_title}\nFav if #{get_game_title}"
    when 700...800
      "#{get_character_name} x #{get_character_name}: my otp"
    when 800...900
      "my dream game is #{get_game_title} but with #{get_character_name} in it #{interjections.sample}"
    when 900...1000
      "#YearOf#{get_character_name.gsub(/[^A-z0-9]/,'')} #{interjections.sample}"
    when 1000...1100
      title = random_from_search_result('search/', {:query=>"way,lay,slay,pay,play,sway,bay,say,day,may", :resources=>"game"}).first[:name]
      "#{title}?\nMore like #{title.downcase.gsub(/[pwlbdsm]+ay(\S*)/, 'bae\1')}, amirite?"
    else
      rand(2) == 1 ? "#TeamBoneless" : "#TeamBoneIn"
    end
  end

  def on_startup
    tweet make_meme
    scheduler.every '48m' do # Tweet something every 24 hours
      tweet make_meme
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
MyBot.new("gamesmemes") do |bot|
  bot.access_token = SETTINGS['ACCESS_TOKEN'] # Token connecting the app to this account
  bot.access_token_secret = SETTINGS['ACCESS_TOKEN_SECRET'] # Secret connecting the app to this account
end
