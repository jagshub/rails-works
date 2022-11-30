# frozen_string_literal: true

class TwitterBot::ProductHuntHi < TwitterBot::Base
  private

  def twitter_consumer_key
    ENV.fetch('TWITTER_PH_HI_CONSUMER_KEY')
  end

  def twitter_consumer_secret
    ENV.fetch('TWITTER_PH_HI_CONSUMER_SECRET')
  end

  def twitter_access_token
    ENV.fetch('TWITTER_PH_HI_ACCESS_TOKEN')
  end

  def twitter_access_secret
    ENV.fetch('TWITTER_PH_HI_ACCESS_SECRET')
  end
end
