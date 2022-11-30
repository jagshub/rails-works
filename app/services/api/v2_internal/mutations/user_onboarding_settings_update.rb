# frozen_string_literal: true

class API::V2Internal::Mutations::UserOnboardingSettingsUpdate < API::V2Internal::Mutations::BaseMutation
  argument :screen, Integer, required: true, camelize: false
  argument :name, String, required: false, camelize: false
  argument :email, String, required: false, camelize: false
  argument :username, String, required: false, camelize: false
  argument :headline, String, required: false, camelize: false
  argument :newsletter_subscription, String, required: false, camelize: false
  argument :confirmed_age, Boolean, required: false, camelize: false
  argument :website_url, String, required: false, camelize: false
  argument :topic_ids, [ID], required: false, camelize: false
  argument :job_search, Boolean, required: false, camelize: false
  argument :remote, Boolean, required: false, camelize: false

  returns API::V2Internal::Types::SettingsType

  def perform
    return error :confirmed_age, 'must be accepted' if inputs.key?(:confirmed_age) && !inputs[:confirmed_age]
    return error :email, :blank if inputs[:screen] == 1 && inputs[:email].blank?

    update_settings inputs, current_user
  end

  private

  SCREEN_1 = 1
  SCREEN_2 = 2

  def update_settings(inputs, current_user)
    node = Users::ProfileSettings.call(
      inputs: inputs,
      user: current_user,
      onboarding: true,
    )

    case inputs[:screen]
    when SCREEN_1
      Subscribers.send_verification_email(
        subscriber: current_user.subscriber,
        first_time: true,
      )
    when SCREEN_2
      Onboardings::Create.call name: :user_signup, user: current_user
    end

    node
  end
end
