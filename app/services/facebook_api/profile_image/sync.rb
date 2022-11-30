# frozen_string_literal: true

module FacebookApi::ProfileImage::Sync
  extend self

  ERROR_MESSAGE = 'Invalid or Missing Facebook token'

  def call(user)
    access_token = user.access_tokens.facebook.first
    token = access_token.try(:token)

    raise SignIn::TokenExpirationError, ERROR_MESSAGE unless access_token&.expired?
    raise SignIn::TokenExpirationError, ERROR_MESSAGE if token.blank?

    url = FacebookApi::GetPicture.call token

    Image::Uploads::AvatarWorker.perform_later(url, user)

    url
  end
end
