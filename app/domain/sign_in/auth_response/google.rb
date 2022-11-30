# frozen_string_literal: true

module SignIn::AuthResponse::Google
  extend self

  PROVIDER = 'google'
  # Note(TC): To track Google One Tap for the interim, we will differentiate the provider
  # here from the traditional google provider to easily track it.
  ONETAP_PROVIDER = 'googleonetap'
  ALL_PROVIDERS = [PROVIDER, ONETAP_PROVIDER].freeze

  # NOTE(rstankov): Documentation - https://github.com/zquestz/omniauth-google-oauth2#auth-hash
  def from_omniauth(auth)
    SignIn::AuthResponse.new do |t|
      t.trusted = true
      t.provider = PROVIDER
      t.social_uid_key = :google_uid
      t.suggested_username = SignIn::SuggestedUsername.call(auth[:info][:name])

      t.default_profile_image = false
      t.user_params = {
        google_uid: auth[:uid],
        name: auth[:info][:name],
        email: auth[:info][:email],
        image: fix_image(auth[:info][:image]),
      }

      if auth[:credentials].present?
        t.token_params = {
          token_type: :google,
          token: auth[:credentials][:token],
          expires_at: Time.zone.at(auth[:credentials][:expires_at]),
        }
      end
    end
  end

  def from_api(token)
    info = External::GoogleApi.decode_mobile_token(token)

    SignIn::AuthResponse.new do |t|
      t.trusted = true
      t.provider = PROVIDER
      t.social_uid_key = :google_uid
      t.suggested_username = SignIn::SuggestedUsername.call(info.name)

      t.default_profile_image = false
      t.user_params = {
        google_uid: info.uid,
        name: info.name,
        email: info.email,
        image: fix_image(info.image),
      }

      t.token_params = {
        token_type: :google,
        token: info.token,
        expires_at: info.expires_at,
      }
    end
  end

  def from_google_one_tap(params)
    raise ArgumentError, 'Invalid auth login provider - Other' if params[:g_csrf_token].blank?

    info = External::GoogleApi.decode_jwt_response(params['credential'])

    SignIn::AuthResponse.new do |t|
      t.provider = ONETAP_PROVIDER
      t.social_uid_key = :google_uid
      t.suggested_username = SignIn::SuggestedUsername.call(info.name)

      t.default_profile_image = false
      t.user_params = {
        google_uid: info.uid,
        name: info.name,
        email: info.email,
        image: fix_image(info.image),
      }

      t.token_params = {
        token_type: :google,
        token: info.token,
        expires_at: info.expires_at,
      }
    end
  end

  # Note(AR): Image formats come from https://developers.google.com/people/image-sizing
  def fix_image(image_url)
    return if image_url.blank?

    # Ensure image is: square, 400px, cropped
    image_url.gsub(/=[swh]\d+(-[cp])?$/, '=s400-c')
  end
end
