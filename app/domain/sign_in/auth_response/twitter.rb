# frozen_string_literal: true

module SignIn::AuthResponse::Twitter
  extend self

  PROVIDER = 'twitter'

  # Note (Lukas Fittl): The twitter_user should be a hash as documented here:
  #   https://dev.twitter.com/rest/reference/get/account/verify_credentials
  #   https://github.com/sferik/twitter/blob/master/lib/twitter/user.rb
  def from_api(params, oauth_app)
    client = ::Twitter::REST::Client.new do |config|
      config.consumer_key        = oauth_app.twitter_consumer_key
      config.consumer_secret     = oauth_app.twitter_consumer_secret
      config.access_token        = params.fetch(:oauth_token)
      config.access_token_secret = params.fetch(:oauth_token_secret)
    end

    twitter_user = client.verify_credentials(include_email: true)

    SignIn::AuthResponse.new do |t|
      t.provider = PROVIDER
      t.social_uid_key = :twitter_uid
      t.suggested_username = twitter_user.screen_name.dup

      t.user_params = {
        twitter_uid: twitter_user.id.to_s,
        twitter_username: twitter_user.screen_name.dup,
        name: twitter_user.name,
        email: twitter_user.email,
        website_url: twitter_user.website.to_s,
        image: twitter_user.profile_image_url.to_s.dup.sub('_normal', ''),
      }

      # Note (LukasFittl): We don't store twitter tokens here since this runs
      #   in the context of a foreign Twitter app using reverse-auth
      t.token_params = {}

      t.created_at = twitter_user.created_at
      t.default_profile_image = twitter_user.default_profile_image?
    end
  end

  def from_omniauth(auth)
    SignIn::AuthResponse.new do |t|
      t.provider = PROVIDER
      t.social_uid_key = :twitter_uid
      t.suggested_username = auth[:info][:nickname]

      t.user_params = {
        twitter_uid: auth[:uid],
        twitter_username: auth[:info][:nickname],
        name: auth[:info][:name],
        email: auth[:info][:email],
        website_url: fetch_website_from_entities(auth[:extra][:raw_info][:entities]),
        image: auth[:info][:image] ? auth[:info][:image].sub('_normal', '') : nil,
        twitter_verified: auth[:extra][:raw_info][:verified] || false,
      }

      t.token_params = {
        token_type: :twitter,
        token: auth[:extra][:access_token].token,
        secret: auth[:extra][:access_token].secret,
        permissions: 'write_access',
      }

      t.created_at = Date.parse(auth[:extra][:raw_info][:created_at] || Time.zone.today.to_s)
      t.default_profile_image = auth[:extra][:raw_info][:default_profile_image] == true
    end
  end

  private

  # Note(andreasklinger): This could/should be `auth[:info][:urls]['Website']`,
  #   but omniauth provides a t.co shortened URL there instead of the actual
  #   website URL. Most likely Twitter changed their API.
  def fetch_website_from_entities(entities)
    entities[:url][:urls].first[:expanded_url] if entities.present? && entities[:url].present?
  end
end
