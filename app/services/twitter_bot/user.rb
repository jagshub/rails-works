# frozen_string_literal: true

class TwitterBot::User < TwitterBot::Base
  attr_reader :user, :access_token

  def initialize(user:)
    @user = user
    @access_token = user.access_tokens.twitter.write_access.first
  end

  def follow(username:)
    twitter_client.follow(username)
  end

  private

  def twitter_consumer_key
    Config.secret(:twitter_key)
  end

  def twitter_consumer_secret
    Config.secret(:twitter_secret)
  end

  def twitter_access_token
    access_token.token
  end

  def twitter_access_secret
    access_token.secret
  end
end
