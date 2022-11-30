# frozen_string_literal: true

module Mobile::Graph::Mutations
  class SignInMerge < BaseMutation
    argument :token, String, required: true

    returns Mobile::Graph::Types::SignInTokenType

    def perform(params)
      social_login = Users::NewSocialLogin.processable.find_by(token: params[:token])

      if social_login.blank?
        return error :base, 'Invalid or expired token'
      end

      oauth_app = OAuth::Application.find_by(id: social_login[:via_application_id])

      if oauth_app.blank?
        return error :base, 'Invalid app for social login'
      end

      ::SignIn.merge_new_social_login(social_login)
      scopes = Doorkeeper::OAuth::Scopes.from_string 'public private'
      user = social_login.user
      token = Doorkeeper::AccessToken.find_or_create_for(
        application: oauth_app,
        resource_owner: user.id,
        scopes: scopes,
      )

      Mobile::Graph::Utils::SignInToken.new(token, user)
    end
  end
end
