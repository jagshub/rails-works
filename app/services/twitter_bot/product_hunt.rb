# frozen_string_literal: true

class TwitterBot::ProductHunt < TwitterBot::Base
  private

  def twitter_consumer_key
    ENV.fetch('TWITTER_BOT_CONSUMER_KEY')
  end

  def twitter_consumer_secret
    ENV.fetch('TWITTER_BOT_CONSUMER_SECRET')
  end

  def twitter_access_token
    ENV.fetch('TWITTER_BOT_ACCESS_TOKEN')
  end

  def twitter_access_secret
    ENV.fetch('TWITTER_BOT_ACCESS_SECRET')
  end
end
