require 'twitter_ebooks'
require 'dotenv'
require 'rest-client'

SETTINGS = Dotenv.load.merge(ENV)

class MyBot < Ebooks::Bot
    attr_accessor 'gb_api_key'

  def configure
    # Consumer details come from registering an app at https://dev.twitter.com/
    # Once you have consumer details, use "ebooks auth" for new access tokens

    self.consumer_key = SETTINGS['CONSUMER_KEY'] # Your app consumer key
    self.consumer_secret = SETTINGS['CONSUMER_SECRET'] # Your app consumer secret
    self.gb_api_key = SETTINGS['GIANTBOMB_API_KEY']

    # Users to block instead of interacting with
    self.blacklist = ['tnietzschequote']

    # Range in seconds to randomize delay when bot.delay is called
    self.delay_range = 1..6
  end

  def get_games
    # RestClient.get ("http://www.giantbomb.com/api/games/?api_key=#{self.gb_api_key}&field_list=name&format=json&limit=100&offset=#{rand 44450}") do |res|
    #   JSON.parse(res, :symbolize_names:true)[:results].first[:name]
    # end
  end

  def get_game
    RestClient.get ("http://www.giantbomb.com/api/games/?api_key=#{self.gb_api_key}&field_list=name&format=json&limit=1&offset=#{rand 44550}") do |res|
      JSON.parse(res, :symbolize_names=>true)[:results].first[:name]
    end
  end

  def on_startup
    tweet "#NameYourJunkAfterAGame #{get_game}"
    scheduler.every '8m' do # Tweet something every 24 hours
      tweet "#NameYourJunkAfterAGame #{get_game}"
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
