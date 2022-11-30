# frozen_string_literal: true

class TwitterBot::Base
  class << self
    def send_tweet(text:, image_url: nil)
      new.send_tweet(text: text.to_s, image_url: image_url)
    end
  end

  def send_tweet(text:, image_url: nil)
    return unless send_tweets?

    image = image_url.present? ? Twitter::Image.open_from_url(image_url) : nil

    if image.present?
      twitter_client.update_with_media text, image
    else
      twitter_client.update text
    end
  end

  private

  def send_tweets?
    Rails.configuration.x.send_tweets.present?
  end

  def twitter_client
    @twitter_client ||= Twitter::REST::Client.new do |config|
      config.consumer_key        = twitter_consumer_key
      config.consumer_secret     = twitter_consumer_secret
      config.access_token        = twitter_access_token
      config.access_token_secret = twitter_access_secret
    end
  end

  def twitter_consumer_key
    raise NotImplementedError, 'You must implement twitter_consumer_key in each kind of Twitter Bot'
  end

  def twitter_consumer_secret
    raise NotImplementedError, 'You must implement twitter_consumer_secret in each kind of Twitter Bot'
  end

  def twitter_access_token
    raise NotImplementedError, 'You must implement twitter_access_token in each kind of Twitter Bot'
  end

  def twitter_access_secret
    raise NotImplementedError, 'You must implement twitter_access_secret in each kind of Twitter Bot'
  end
end
