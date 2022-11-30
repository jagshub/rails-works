# frozen_string_literal: true

module Graph::Mutations
  class NewSocialLoginSeparate < BaseMutation
    returns Boolean

    def perform
      new_social_login_id = SignIn.session_new_social_login_id(context[:session])
      return { node: false } if new_social_login_id.blank?

      new_social_login = Users::NewSocialLogin.find(new_social_login_id)

      # NOTE(DZ): Check in case of race condition between email and this mutation.
      # If successful, sign them in.
      if !new_social_login.processable?
        SignIn.reset_session_new_social_login_id(context[:session])

        { node: false }
      else
        auth_response = SignIn.auth_response_from_new_social_login(new_social_login)
        user = SignIn.process_auth_response(
          auth_response,
          new_social_login.via_application_id,
        )
        context[:session][:user_id] = user.id
        SignIn.reset_session_new_social_login_id(context[:session])

        { node: new_social_login.separated! }
      end
    end
  end
end
