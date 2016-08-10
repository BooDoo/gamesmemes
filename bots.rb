require 'json'
require 'tempfile'
require 'dotenv'
require 'rest-client'
require 'twitter_ebooks'
require_relative 'queneau'

SETTINGS = Dotenv.load.merge(ENV)

GAME_ENGINES = ["Pyrogenesis", "Aleph One", "Clausewitz", "RPG Maker", "Ren'Py", "PlayN", "Starling Framework", "Real Virtuality", "Cube", "Spring", "Infinity Engine", "Buildbox", "Enigma Engine", "Stratagus", "IW engine", "BRender", "Adventure Game Studio", "Core3D", "Moai SDK", "Cube 2", "Jedi", "Kivy", "id Tech 4", "id Tech 1","Source 2", "Riot Engine", "Shark 3D", "Blend4Web", "Luminous Studio", "Anura", "Source", "GoldSrc", "Cocos2d, Cocos2d-x, Cocos2d-html5", "GameMaker: Studio", "StepMania", "TOSHI", "Crystal Space", "ORX", "Adventure Game Interpreter", "Anvil", "BigWorld", "Bork3D Game Engine", "C4 Engine", "Chrome Engine", "CryEngine", "Crystal Tools", "Dagor Engine", "Dunia Engine", "ego", "Flare3D", "Fox Engine", "Freescape", "Frostbite", "Gamebryo", "Jade", "LithTech", "LyN", "MT Framework", "PhyreEngine", "Pie in the Sky", "Rockstar Advanced Game Engine","SAGE", "Unigine", "V-Play Game Engine", "Vicious Engine", "Vision", "RenderWare", "Unity", "Unreal Engine", "SCUMM", "Torque3D", "LÖVE", "4A Engine", "VRAGE", "ONScripter", "Game Editor", "OpenClonk", "HPL Engine", "Coldstone", "Panta Rhei", "Turbulenz", "ShiVa", "id Tech 2","id Tech 2","id Tech 3", "id Tech 5", "UbiArt Framework", "Alamo", "Odyssey Engine", "PlayCanvas", "Creation Engine", "REDengine", "Panda3D", "OGRE", "DimensioneX Multiplayer Engine", "Flexible Isometric Free Engine", "ioquake3", "Flixel", "Sierra's Creative Interpreter","Blender"]
NUMPAD_ARROWS = [nil,'↙','↓','↘','←',nil,'→','↖','↑','↗']
ALL_ARROWS = ["\u2190","\u2191","\u2192","\u2193","\u2194","\u2195","\u2196","\u2197","\u2198","\u2199","\u25b2","\u25bc","\u25c0","\u25b6","\u2794","\u2798","\u2799","\u279a","\u279b","\u279c","\u279d","\u279e","\u279f","\u27a0","\u27a1","\u27a2","\u27a3","\u27a4","\u27a5","\u27a6","\u21aa","\u21a9","\u219a","\u219b","\u219c","\u219d","\u219e","\u219f","\u21a0","\u21a1","\u21a2","\u21a3","\u21a4","\u21a6","\u21a5","\u21a7","\u21a8","\u21ab","\u21ac","\u21ad","\u21ae","\u21af","\u21b0","\u21b1","\u21b2","\u21b4","\u21b3","\u21b5","\u21b6","\u21b7","\u21b8","\u21b9","\u21ba","\u21bb","\u27f2","\u27f3","\u21bc","\u21bd","\u21be","\u21bf","\u21c0","\u21c1","\u21c2","\u21c3","\u21c4","\u21c5","\u21c6","\u21c7","\u21c8","\u21c9","\u21ca","\u21cb","\u21cc","\u21cd","\u21cf","\u21cf","\u21cf","\u21cf","\u21cf","\u21cf","\u21cf","\u21d5","\u21d6","\u21d7","\u21d8","\u21d9","\u21d9","\u21f3","\u21da","\u21db","\u21dc","\u21dd","\u21de","\u21df","\u21df","\u21df","\u21e0","\u21e1","\u21e2","\u21e3","\u21e4","\u21e5","\u21e6","\u21e8","\u21e9","\u21ea","\u21e7","\u21eb","\u21ec","\u21ed","\u21ee","\u21ef","\u21f0","\u21f1","\u21f2","\u21f4","\u21f5","\u21f6","\u21f7","\u21f8","\u21f9","\u21fa","\u21fa","\u21fb","\u21fc","\u21ff","\u27f0","\u27f1","\u27f4","\u27f5","\u27f6","\u27f7","\u27f8","\u27f9","\u27fd","\u27fe","\u27fa","\u27fb","\u27fc","\u27ff","\u2900","\u2901","\u2905","\u2902","\u2903","\u2904","\u2906","\u2907","\u2908","\u2909","\u290a","\u290b","\u290c","\u290d","\u290e","\u290f","\u2910","\u2911","\u2912","\u2913","\u2914","\u2915","\u2916","\u2917","\u2918","\u2919","\u2919","\u291a","\u291b","\u291c","\u291d","\u291e","\u2921","\u2922","\u2923","\u2924","\u2925","\u2926","\u2927","\u2928","\u2929","\u292a","\u292d","\u292e","\u292f","\u2930","\u2931","\u2932","\u2933","\u293b","\u2938","\u293e","\u293f","\u293a","\u293c","\u293d","\u2934","\u2935","\u2936","\u2937","\u2939","\u2940","\u2941","\u2942","\u2943","\u2944","\u2945","\u2946","\u2947","\u2948","\u2949","\u2952","\u2953","\u2954","\u2955","\u2956","\u2957","\u2958","\u2959","\u295a","\u295b","\u295c","\u295d","\u295e","\u295f","\u2960","\u2961","\u2962","\u2963","\u2964","\u2965","\u2966","\u2967","\u2968","\u2969","\u296a","\u296b","\u296c","\u296d","\u296e","\u296f","\u2970","\u2971","\u2972","\u2973","\u2974","\u2975","\u2976","\u2977","\u2978","\u2979","\u297a","\u297b","\u27a7","\u27a8","\u27a9","\u27aa","\u27ab","\u27ac","\u27ad","\u27ae","\u27af","\u27b1","\u27b2","\u27b3","\u27b4","\u27b5","\u27b6","\u27b7","\u27b8","\u27b9","\u27ba","\u27bb","\u27bc","\u27bd","\u27be","\u2b05","\u2b06","\u2b07","\u23ce","\u2b0e","\u2b0f","\u2b10","\u2b11","\u2608","\u2607","\u2343","\u2344","\u2347","\u2348","\u2350","\u2357","\u234c","\u2353","\u234d","\u2354","\u234f","\u2356","\u2345","\u2346","\u2b08","\u2b09","\u2b0a","\u2b0b","\u2b0c","\u2b0d","\u2b00","\u2b01","\u2b02","\u2b03","\u2b04"]
MOVES = JSON.parse(File.read('moves.json'))
NUM_INPUTS = ["236", "623", "214", "421", "41236", "6237", "4219", "63214", "632146", "89632147", "8963214789632147", "412369", "632147", "2141236", "2363214", "21412364", "23632146", "[4]6", "[1]9", "[2]8", "[3]7", "[4]646", "[1]919", "[2]828", "[3]737", "4123641236", "6321463214", "4123632146", "6321412364"]
ATTACK_COMMANDS = ["P", "K", "S", "HS", "D", "LP", "MP", "HP", "LK", "MK", "HK", "PPP", "KKK"]
BUTTONS = {
  "1": '↙',
  "2": '↓',
  "3": '↘',
  "4": '←',
  "6": '→',
  "7": '↖',
  "8": '↑',
  "9": '↗',
  P: "\u24C5",
  K: "\u24C0",
  H: "\u24BD",
  S: "\u24C8",
  M: "\u24C2",
  D: "\u24B9",
  L: "\u24C1"
}

class MyBot < Ebooks::Bot
  attr_accessor 'gb_api_key', 'gb_api', 'gb_params'
  attr_accessor 'accessories_max', 'characters_max', 'companies_max', 'concepts_max', 'franchises_max', 'games_max', 'game_ratings_max', 'genres_max', 'locations_max', 'objects_max', 'people_max', 'platforms_max', 'promos_max', 'rating_boards_max', 'regions_max', 'releases_max', 'reviews_max', 'themes_max', 'user_reviews_max', 'videos_max', 'video_types_max'
  attr_accessor 'moves_qb'

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

    # Bespoke, artisinal contents
    @title_hashtags = ["#NameYourJunkAfterAGame", "#DescribeYourSexLifeWithAGame"]
    @interjections = ["lol", "ayyyy lmao", "wtf right?!", "tho", "lmfao", "lmaoooooo", "iM DyING", "*SCREAMING*", "#TRUTH", "#LIFE", "#blessed"]
    @softeners = ["imo", "tbqh", "tho", "though", "prolly", "probably", "I think", "just saying", "sorry", "sorry, not sorry"]
    @sins = ["romanced CHAR", "slept with CHAR", "had carnal relations with CHAR", "left CHAR to die", "never cared about CHAR", "cried irl over CHAR", "RPed as CHAR", "LARPed as CHAR", "shipped myself with CHAR", "a shrine to CHAR", "coveted my neighbor's CHAR", "taken CHAR's name in vain", "not one fuck to give about CHAR", "known CHAR...biblically."]
    @engines = GAME_ENGINES
    @moves = MOVES
    @moves_qb = Queneau.new(@moves)
    @trivia = ["did you know?", "#tmyk", "wow!", "I can't believe", "you won't believe", "can you believe", "were you aware", "it's amazing that", "who could guess", "just learned", "TILT:", "oh wow", "amazing!", "NO WAY!"]
    @solo_activities = ["smoked weed", "got drunk", "took you to prom", "got pregnant", "took shrooms", "tripped balls", "went to ur school", "did let's plays", "proposed to you", "were gay", "were gay as hell"]
    @memes = [
      {label: 'bogost_games', action: :tweet, gen: proc {
        "#{get_game_title} would be a lot better without characters #{softeners.sample}"
      }},
      {label: 'favegames', action: :tweet, gen: proc {
        "#7favegames\n#{get_game_titles(7).join("\n")}".chars.take(140).join("")
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
        "#{title_hashtags.sample}\nRT if #{get_game_title}\nLike if #{get_game_title}"
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
      {label: 'upgrade', action: :tweet, gen: proc{
        img_urls = []
        2.times {img_urls.push get_character_image}

        media_ids = img_urls.map do |img_url|
          Tempfile.open("multi_img") do |f|
            f.write(RestClient.get(img_url))
            twitter.upload(File.new(f.path))
          end
        end

        media_ids.insert(1,
              twitter.upload(File.new('./upgrade.jpg'))
        )

        ["", {:media_ids=>media_ids.join(',')}]
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

        preface = ["#FourGameCrushes", "same voice actor"].sample

        ["#{preface} #{interjections.sample}", {:media_ids=>media_ids.join(',')}]
      }},
      {label: 'secret_moves', action: :tweet, gen: method(:make_move)}
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

  def circle_letter_up(char)
    # this is a stupid method I won't use, probably

    # if Latin char, return circled upcase version
    if Range.new("A".."z").include? char
      # 9333 is the ordinal offset for circled uppercase
      return [(n.upcase.ord + 9333)].pack("U")
    else
      return char
    end
  end

  def circle_letter_down(char)
    # stupid method
    if Range.new("A".."z").include? char
      #9327 is ordinal offset for circle lowercase
      return [(n.downcase.ord + 9327)].pack("U")
    else
      return char
    end
  end

  def get_button(char)
    BUTTONS.fetch(char.to_sym, char)
  end

  def get_buttons(command)
    command.chars.map(&method(:get_button)).join
  end

  def move_name(length=nil)
    @moves_qb.fill(length)
  end

  def move_input(rarity=nil)
    # take a set input motion and 1-3 key presses
    command = "#{NUM_INPUTS.sample}+#{ATTACK_COMMANDS.sample(rand(3)+1).join('+')}"
    get_buttons(command)
  end

  def make_move(length=nil, rarity=nil)
    "#{move_name}: \n    #{move_input}"
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

  def make_meme(meme=nil)
    meme ||= @memes.sample
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
