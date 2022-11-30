# frozen_string_literal: true

class TwitterApi::ProfileImage::Sync
  attr_reader :user

  class << self
    def call(user)
      new(user).call
    end
  end

  def initialize(user)
    @user = user
  end

  def call
    image_url = profile_image_url
    Image::Uploads::AvatarWorker.perform_later(image_url, user)

    image_url
  rescue Twitter::Error::NotFound, Twitter::Error::Forbidden, Twitter::Error::ServiceUnavailable
    raise SignIn::TokenExpirationError, 'Invalid or Missing Token'
  end

  private

  def profile_image_url
    twitter_user = TwitterApi::Client.for_user(user).api_client.user(user.twitter_username)
    twitter_user.profile_image_url.to_s.dup.sub('_normal', '')
  end
end
