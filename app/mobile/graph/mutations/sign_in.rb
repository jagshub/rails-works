# frozen_string_literal: true

module Mobile::Graph::Mutations
  class SignIn < BaseMutation
    argument :app, String, required: true
    argument :login_provider, String, required: true
    argument :oauth_token, String, required: false
    argument :oauth_token_secret, String, required: false
    argument :info, Mobile::Graph::Types::SignInInfoInputType, required: false
    argument :force, Boolean, required: false

    returns Mobile::Graph::Types::SignInTokenType

    def perform(params)
      oauth_app = OAuth::Application.find_by(twitter_app_name: params[:app])

      if oauth_app.blank?
        return error :base, 'Invalid app name'
      end

      auth_response = ::SignIn.auth_response_from_api(params, oauth_app)

      if auth_response.blank?
        return error :base, 'Invalid or expired token'
      end

      unless params[:force]
        new_social_login = ::SignIn.detect_duplicate_user(
          auth_response,
          oauth_app.id,
          skip_email_link_tracking: true,
        )

        if new_social_login.present? && !new_social_login.merged?
          return error :duplicate_account, ::SignIn.find_provider_for_user(new_social_login.user)
        end
      end

      user = ::SignIn.process_auth_response(auth_response, oauth_app.id)
      scopes = Doorkeeper::OAuth::Scopes.from_string 'public private'
      token = Doorkeeper::AccessToken.find_or_create_for(application: oauth_app, resource_owner: user.id, scopes: scopes)

      Mobile::Graph::Utils::SignInToken.new(token, user)
    end
  end
end
