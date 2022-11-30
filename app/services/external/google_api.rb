# frozen_string_literal: true

module External::GoogleApi
  extend self

  # Documentation:
  # - https://github.com/google/google-id-token
  # - https://developers.google.com/identity/sign-in/android/backend-auth
  # - https://developers.google.com/identity/sign-in/ios/backend-auth
  def decode_mobile_token(token)
    result = mobile_token_validate(token)

    OpenStruct.new(
      token: token,
      uid: result['sub'],
      image: result['picture'],
      email: result['email'],
      name: result['name'],
      expires_at: Time.at(result['exp']).in_time_zone,
    )
  end

  # The One Tap workflow will return a credential field in the request.
  # This data is B64 encoded and is a JWT token. We can decrypt it
  # using our Google Client ID. The response is almost exactly the
  # auth response from OmniAuth
  def decode_jwt_response(encoded_credential)
    result = decode_response(encoded_credential)

    OpenStruct.new(
      token: encoded_credential,
      uid: result['sub'],
      image: result['picture'],
      email: result['email'],
      name: result['name'],
      expires_at: Time.at(result['exp']).in_time_zone,
    )
  end

  private

  # NOTE(rstankov): We have two mobile tokens, we have to check both
  #  - ios, uses our regular once
  #  - android, uses one special for android
  def mobile_token_validate(token)
    GoogleIDToken::Validator.new.check(token, Config.google_login_client_id)
  rescue GoogleIDToken::SignatureError, GoogleIDToken::CertificateError, GoogleIDToken::AudienceMismatchError
    GoogleIDToken::Validator.new.check(token, Config.google_android_login_client_id)
  end

  def decode_response(credential)
    JWT.decode(credential, nil, false).first
  end
end
