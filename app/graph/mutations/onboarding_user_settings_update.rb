# frozen_string_literal: true

module Graph::Mutations
  class OnboardingUserSettingsUpdate < BaseMutation
    argument :name, String, required: false
    argument :email, String, required: false
    argument :username, String, required: false
    argument :headline, String, required: false
    argument :newsletter_subscription, String, required: false
    argument :confirmed_age, Boolean, required: false
    argument :g_re_captcha, String, required: false
    argument :onboarding_step, String, required: true

    argument :website_url, String, required: false
    argument :topic_ids, [ID], required: false
    argument :job_search, Boolean, required: false
    argument :remote, Boolean, required: false

    returns Graph::Types::SettingsType
    field :viewer, Graph::Types::ViewerType, null: true

    require_current_user
    def perform(inputs)
      return error :confirmed_age, 'must be accepted' if inputs.key?(:confirmed_age) && !inputs[:confirmed_age]
      return error :g_re_captcha, 'complete captcha' if inputs.key?(:g_re_captcha) && !Captcha.verify_user(current_user, inputs[:g_re_captcha])
      return error :email, :blank if inputs[:onboarding_step] == '1' && inputs[:email].blank?

      update_settings inputs, current_user
    end
    # rubocop:enable

    private

    def update_settings(inputs, current_user)
      is_email_changed = current_user.email != inputs[:email]

      node = Users::ProfileSettings.call(
        inputs: inputs,
        user: current_user,
        onboarding: true,
      )

      case inputs[:onboarding_step]
      when '1'
        SpamChecks.check_user_signup(current_user) if is_email_changed
        Subscribers.send_verification_email(
          subscriber: current_user.subscriber,
          first_time: true,
        )
      when '2'
        Onboardings::Create.call name: :user_signup, user: current_user
      end

      { node: node, viewer: current_user.reload }
    end
  end
end
