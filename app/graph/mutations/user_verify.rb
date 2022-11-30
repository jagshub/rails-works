# frozen_string_literal: true

module Graph::Mutations
  class UserVerify < BaseMutation
    argument :g_recaptcha_response, String, required: true

    require_current_user

    returns String

    def perform(g_recaptcha_response:)
      if Captcha.verify_user(current_user, g_recaptcha_response)
        current_user.email.present? ? Routes.root_path : Routes.welcome_onboarding_path(next: Routes.root_path)
      else
        error :base, :bad_request
      end
    end
  end
end
