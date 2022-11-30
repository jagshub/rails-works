# frozen_string_literal: true

module FacebookApi::GetPicture
  extend self

  def call(token)
    client = FacebookApi::Koala.call token
    client.get_picture_data('me', type: :large)['data']['url']
  rescue Koala::Facebook::AuthenticationError, Koala::Facebook::ServerError
    raise SignIn::TokenExpirationError, 'Invalid or Missing Facebook token'
  end
end
