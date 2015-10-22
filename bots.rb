require 'twitter_ebooks'
require 'tempfile'
require 'dotenv'
require 'rest-client'

SETTINGS = Dotenv.load.merge(ENV)

NUMPAD_ARROWS = ['','↙','↓','↘','←','','→','↖','↑','↗']
GAME_ENGINES = ["Pyrogenesis", "Aleph One", "Clausewitz", "RPG Maker", "Ren'Py", "PlayN", "Starling Framework", "Real Virtuality", "Cube", "Spring", "Infinity Engine", "Buildbox", "Enigma Engine", "Stratagus", "IW engine", "BRender", "Adventure Game Studio", "Core3D", "Moai SDK", "Cube 2", "Jedi", "Kivy", "id Tech 4", "id Tech 1","Source 2", "Riot Engine", "Shark 3D", "Blend4Web", "Luminous Studio", "Anura", "Source", "GoldSrc", "Cocos2d, Cocos2d-x, Cocos2d-html5", "GameMaker: Studio", "StepMania", "TOSHI", "Crystal Space", "ORX", "Adventure Game Interpreter", "Anvil", "BigWorld", "Bork3D Game Engine", "C4 Engine", "Chrome Engine", "CryEngine", "Crystal Tools", "Dagor Engine", "Dunia Engine", "ego", "Flare3D", "Fox Engine", "Freescape", "Frostbite", "Gamebryo", "Jade", "LithTech", "LyN", "MT Framework", "PhyreEngine", "Pie in the Sky", "Rockstar Advanced Game Engine","SAGE", "Unigine", "V-Play Game Engine", "Vicious Engine", "Vision", "RenderWare", "Unity", "Unreal Engine", "SCUMM", "Torque3D", "LÖVE", "4A Engine", "VRAGE", "ONScripter", "Game Editor", "OpenClonk", "HPL Engine", "Coldstone", "Panta Rhei", "Turbulenz", "ShiVa", "id Tech 2","id Tech 2","id Tech 3", "id Tech 5", "UbiArt Framework", "Alamo", "Odyssey Engine", "PlayCanvas", "Creation Engine", "REDengine", "Panda3D", "OGRE", "DimensioneX Multiplayer Engine", "Flexible Isometric Free Engine", "ioquake3", "Flixel", "Sierra's Creative Interpreter","Blender"]

class MyBot < Ebooks::Bot
  attr_accessor 'gb_api_key', 'gb_api', 'gb_params'
  attr_accessor 'accessories_max', 'characters_max', 'companies_max', 'concepts_max', 'franchises_max', 'games_max', 'game_ratings_max', 'genres_max', 'locations_max', 'objects_max', 'people_max', 'platforms_max', 'promos_max', 'rating_boards_max', 'regions_max', 'releases_max', 'reviews_max', 'themes_max', 'user_reviews_max', 'videos_max', 'video_types_max'

  attr_reader 'map_names'
  attr_reader 'title_hashtags', 'interjections', 'solo_activities', 'sins', 'softeners', 'trivia', 'engines'
  attr_reader 'memes'

  def configure
    # Consumer details come from registering an app at https://dev.twitter.com/
    # Once you have consumer details, use "ebooks auth" for new access tokens

    self.consumer_key = SETTINGS['CONSUMER_KEY'] # Your app consumer key
    self.consumer_secret = SETTINGS['CONSUMER_SECRET'] # Your app consumer secret
    self.gb_api_key = SETTINGS['GIANTBOMB_API_KEY']
    self.gb_api = RestClient::Resource.new("http://www.giantbomb.com/api")
    self.gb_params = {:api_key => gb_api_key, :format => :json, :field_list => 'name'}

    # High count of some GB API resource ids:
    # N.B.: ids are 1-indexed
    # TODO: read on load(?) and persist(?)
    # as of 9/1/15
    self.accessories_max = 85
    self.characters_max = 31242
    # self.chats_max = 0
    self.companies_max = 10835
    self.concepts_max = 7880
    self.franchises_max = 3233
    self.games_max = 46612
    self.game_ratings_max = 32
    self.genres_max = 50
    self.locations_max = 4777
    self.objects_max = 5958
    self.people_max = 149495
    self.platforms_max = 142
    self.promos_max = 50
    self.rating_boards_max = 6
    self.regions_max = 4
    self.releases_max = 71986
    self.reviews_max = 666
    self.themes_max = 30
    # self.types_max = returns 0-indexed list of objects [{}, {}]
    self.user_reviews_max = 27078
    self.videos_max = 9550
    self.video_types_max = 14

    # Bespoke, artisinal content:
    @title_hashtags = ["#NameYourJunkAfterAGame", "#DescribeYourSexLifeWithAGame"]
    @interjections = ["lol", "ayyyy lmao", "wtf right?!", "tho", "lmfao", "lmaoooooo", "iM DyING", "*SCREAMING*", "#TRUTH", "#LIFE", "#blessed"]
    @softeners = ["imo", "tbqh", "tho", "though", "prolly", "probably", "I think", "just saying", "sorry", "sorry, not sorry"]
    @sins = ["romanced CHAR", "slept with CHAR", "had carnal relations with CHAR", "left CHAR to die", "never cared about CHAR", "cried irl over CHAR", "RPed as CHAR", "LARPed as CHAR", "shipped myself with CHAR", "a shrine to CHAR", "coveted my neighbor's CHAR", "taken CHAR's name in vain", "not one fuck to give about CHAR", "known CHAR...biblically."]
    @engines = GAME_ENGINES
    @trivia = ["did you know?", "#tmyk", "wow!", "I can't believe", "you won't believe", "can you believe", "were you aware", "it's amazing that", "who could guess", "just learned", "TILT:", "oh wow", "amazing!", "NO WAY!"]
    @solo_activities = ["smoked weed", "got drunk", "took you to prom", "got pregnant", "took shrooms", "tripped balls", "went to ur school", "did let's plays", "proposed to you", "were gay", "were gay as hell"]
    @memes = [
      {label: 'bogost_games', action: :tweet, gen: proc {
        "#{get_game_title} would be a lot better without characters #{softeners.sample}"
      }},
      {label: 'title_hashgags', action: :tweet, gen: proc {
        "#{title_hashtags.sample} #{get_game_title}"
      }},
      {label: 'character_confessions', action: :tweet, gen: proc {
        character = get_character_name
        sin = sins.sample.gsub(/CHAR/, character)
        "Forgive me father, for I have #{sin} #GameConfessions"
      }},
      {label: 'dad_games', action: :tweet, gen: proc {
        dad_terms = ["dead", "deadly", "bad", "sad", "rad", "radical"]
        dad_query = dad_terms.sample(4).join(",")
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
      {label: 'made_in', action: :tweet, gen: proc {
        "#{trivia.sample} #{get_game_title} was made in #{engines.sample}!?"
      }},
      {label: 'year_of_character', action: :tweet, gen: proc {
        "#YearOf#{get_character_name.gsub(/[^A-z0-9]/,'')} #{interjections.sample}"
      }},
      {label: 'netflix', action: :tweet, gen: proc {
        "when will #Netflix make a #{get_game_title} show #{interjections.sample}"
      }},
      {label: 'bae_games', action: :tweet, gen: proc {
        # We need to be more restrictive with our search complexity....
        bae_terms = ["way", "lay", "slay", "pay", "play", "sway" "bay", "say", "day", "may"]
        bae_query = bae_terms.sample(4).join(",")
        title = random_from_search_result('search/', {:query=>query, :resources=>"game"}).first[:name]
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
      {label: 'swish', action: :pictweet, gen: proc {
        img_url = get_character_image
        img_type = File.extname(img_url)[1..-1]
        Tempfile.open("tmp_pic") do |f|
          f.write(RestClient.get(img_url))
          ["SWISH!", f.path, {:type=>img_type}]
        end
      }},
      {label: 'hes_cute', action: :tweet, gen: proc{
        media_ids = [twitter.upload(File.new('./hescute.jpg'))]
        img_url = get_character_image
        img_type = File.extname(img_url)[1..-1]
        Tempfile.open("tmp_pic") do |f|
          f.write(RestClient.get(img_url))
          media_ids.push twitter.upload(File.new(f.path))
        end

        ["#{interjections.sample}", {:media_ids=>media_ids.join(',')}]
      }},
      {label: 'trump', action: :pictweet, gen: proc{
        img_url = get_character_image
        img_type = File.extname(img_url)[1..-1]
        Tempfile.open("tmp_pic") do |f|
          f.write(RestClient.get(img_url))
          ["#PresCandidatesBetterThanTrump", f.path, {:type=>img_type}]
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
    params = {:limit => limit, :offset => rand(games_max - limit)}
    params = gb_params.merge(params)
    gb_api['games/'].get(:params => params, &map_names)
  end

  def get_game_title
    get_game_titles(1).first
  end

  def get_character_names(limit=2)
    params = {:limit => limit, :offset => rand(characters_max - limit)}
    params = gb_params.merge(params)
    gb_api['characters/'].get(:params => params, &map_names)
  end

  def get_character_name
    get_character_names(1).first
  end

  def get_character_images(limit=2)
    params = gb_params.merge({:limit=>limit, :field_list=>'name,image', :offset=>rand(characters_max - limit)})
    # TODO: This fails very ungracefully when an image isn't available!
    JSON.parse(gb_api['characters/'].get(:params => params), :symbolize_names=>true)[:results].map {|c| c[:image][:super_url]}
  end

  def get_character_image
    get_character_images(1).first
  end

  def split_keep(input, pattern=/([\.\?\!])/)
    return input.split(pattern).each_slice(2).map(&:join)
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
