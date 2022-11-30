# frozen_string_literal: true

module SignIn::AuthResponse::Facebook
  extend self

  PROVIDER = 'facebook'

  def from_api(token)
    facebook_user = FacebookApi::BasicInfo.call(token)
    return if facebook_user.blank?

    SignIn::AuthResponse.new do |t|
      t.provider = PROVIDER
      t.social_uid_key = :facebook_uid
      t.suggested_username = SignIn::SuggestedUsername.call(facebook_user['name'])

      t.user_params = {
        facebook_uid: facebook_user['id'],
        name: facebook_user['name'],
        email: facebook_user['email'],
        website_url: facebook_user['website'],
        image: facebook_user['picture']['data']['url'],
      }

      # Note(LukasFittl): We don't store tokens here for now to keep it simple
      t.token_params = {}

      t.default_profile_image = false
    end
  end

  def from_omniauth(auth)
    SignIn::AuthResponse.new do |t|
      t.provider = PROVIDER
      t.social_uid_key = :facebook_uid
      t.suggested_username = SignIn::SuggestedUsername.call(auth[:info][:name])

      t.user_params = {
        facebook_uid: auth[:uid],
        name: auth[:info][:name],
        email: auth[:info][:email],
        image: auth[:info][:image],
        website_url: auth[:info][:urls].present? ? auth[:info][:urls][:Website] : nil,
      }

      if auth[:credentials].present?
        t.token_params = {
          token_type: :facebook,
          token: auth[:credentials][:token],
          expires_at: Time.zone.at(auth[:credentials][:expires_at]),
        }
      end

      t.default_profile_image = false
    end
  end
end
