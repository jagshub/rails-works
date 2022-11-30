# frozen_string_literal: true

module FacebookApi::PutPicture
  extend self

  def call(user, image:, text:)
    access_token = user.access_tokens.facebook.write_access.first
    return if access_token.blank?

    graph = Koala::Facebook::API.new(access_token.token, Config.secret(:facebook_app_secret))
    graph.put_picture(image, caption: text)
  rescue Koala::Facebook::AuthenticationError, Koala::Facebook::ClientError
    nil
  end
end
