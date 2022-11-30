# frozen_string_literal: true

class SignIn::AuthResponse
  SOCIAL_ATTRIBUTES = %i(facebook_uid twitter_uid google_uid apple_uid).freeze

  class << self
    def from_web_request(request)
      if request.env['omniauth.auth']
        from_omniauth(request.env['omniauth.auth'])
      else
        SignIn::AuthResponse::Google.from_google_one_tap(request.params)
      end
    end

    def from_omniauth(auth_data)
      case auth_data.provider
      when 'facebook' then SignIn::AuthResponse::Facebook.from_omniauth(auth_data)
      when 'twitter' then SignIn::AuthResponse::Twitter.from_omniauth(auth_data)
      when 'google_oauth2' then SignIn::AuthResponse::Google.from_omniauth(auth_data)
      when 'apple' then SignIn::AuthResponse::Apple.from_omniauth(auth_data)
      else raise ArgumentError, "Invalid omniauth data provider - #{ auth_data.provider }"
      end
    end

    def from_api(params, oauth_app)
      case params[:login_provider]
      when 'facebook' then SignIn::AuthResponse::Facebook.from_api(params.fetch(:oauth_token))
      when 'google' then SignIn::AuthResponse::Google.from_api(params.fetch(:oauth_token))
      when 'twitter' then SignIn::AuthResponse::Twitter.from_api(params, oauth_app)
      when 'apple' then SignIn::AuthResponse::Apple.from_api(params)
      else
        raise ArgumentError, "Invalid auth login provider - #{ params[:login_provider] }"
      end
    end

    def from_json(json)
      new do |t|
        json.deep_symbolize_keys.each do |k, v|
          t.public_send("#{ k }=", v)
        end
      end
    end
  end

  attr_accessor :suggested_username
  attr_accessor :user_params
  attr_accessor :token_params
  attr_accessor :provider
  attr_accessor :social_uid_key
  attr_accessor :created_at
  attr_accessor :default_profile_image
  attr_accessor :trusted

  alias default_profile_image? default_profile_image

  def initialize
    yield self if block_given?
  end

  def email
    user_params[:email] || user_params['email']
  end

  def social_uid
    user_params[social_uid_key.to_sym] || user_params[social_uid_key.to_s]
  end

  def find_user
    User.not_trashed.find_by(social_uid_key => social_uid)
  end
end
