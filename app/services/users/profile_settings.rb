# frozen_string_literal: true

module Users::ProfileSettings
  extend self

  def call(inputs:, user:, onboarding: false)
    form = My::UserSettings.new(user, onboarding: onboarding)

    inputs[:jobs_newsletter_subscription] = Jobs::Newsletter::Subscriptions::SUBSCRIBED if !!inputs[:job_search]

    form.update inputs

    form
  end
end
