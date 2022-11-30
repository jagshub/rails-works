# frozen_string_literal: true

module SignIn::AuthResponse::Apple
  extend self

  def from_omniauth(auth)
    SignIn::AuthResponse.new do |t|
      name = extract_name(auth[:info][:name])

      t.provider = 'apple'
      t.social_uid_key = :apple_uid
      t.suggested_username = SignIn::SuggestedUsername.call(name)

      t.user_params = {
        apple_uid: auth[:uid],
        name: name,
        email: auth[:info][:email],
      }

      t.token_params = {
        token_type: :apple,
        token: auth[:credentials][:token],
        expires_at: Time.zone.at(auth[:credentials][:expires_at]),
      }

      t.default_profile_image = false
    end
  end

  def from_api(params)
    decoded_token = decode_apple_jwt(params[:oauth_token])

    return if decoded_token.nil?

    uuid = decoded_token['sub']
    email = decoded_token['email']

    info = params[:info]

    # Info can be a gql input type if it's coming through a mutation.
    # It needs to be tranformed into the original format before checking for the name.
    if info&.is_a?(GraphQL::Schema::InputObject)
      info = camelize_keys(info.to_hash)
    end

    name = info ? info[:fullName].values_at(:givenName, :middleName, :familyName).reject(&:blank?).join(' ').presence : nil
    name ||= extract_name(email)

    SignIn::AuthResponse.new do |t|
      t.provider = 'apple'
      t.social_uid_key = :apple_uid
      t.suggested_username = SignIn::SuggestedUsername.call(name)

      t.user_params = {
        apple_uid: uuid,
        name: name,
        email: email,
      }

      t.token_params = {
        token_type: :apple,
        token: params[:oauth_token],
        expires_at: nil,
      }

      t.default_profile_image = false
    end
  end

  private

  # NOTE(rstankov): Many apple user.name are their emails
  def extract_name(name)
    name.to_s.gsub(/@.*/, '').tr('.', ' ').titlecase
  end

  def camelize_keys(info)
    info.deep_transform_keys { |k| k.to_s.camelize(:lower).to_sym }
  end

  # NOTE(rstankov): Documentation: https://developer.apple.com/documentation/sign_in_with_apple/generate_and_validate_tokens
  def decode_apple_jwt(jwt_token)
    options = {
      verify_iss: true,
      iss: 'https://appleid.apple.com',
      verify_iat: true,
      verify_aud: true,
      aud: ['com.producthunt.producthuntbundleid', 'com.producthunt.apple-login', 'com.producthunt.ProductHuntClient'],
      algorithms: ['RS256'],
      jwks: fetch_jwks,
    }

    JWT.decode(jwt_token, nil, true, options).first
  rescue JWT::DecodeError => e
    ErrorReporting.report_warning(e, extra: { apple_jwt: jwt_token })
    nil
  end

  def fetch_jwks
    Rails.cache.fetch('sign-in-with-apple-jwk', expires_in: 1.day) do
      response = Net::HTTP.get_response(URI.parse('https://appleid.apple.com/auth/keys'))
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end
