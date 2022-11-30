# frozen_string_literal: true

module UserOnboarding
  extend self

  def captcha_disabled?
    Setting.enabled?('onboarding_captcha_disabled')
  end

  def completed?(user)
    user.onboardings.completed.where(name: %i(mobile user_signup)).present? || user_from_old_onboarding?(user)
  end

  private

  NEW_ONBOARDING_LIVE_DATE ||= '11/11/2020'

  def user_from_old_onboarding?(user)
    user.created_at < Date.parse(NEW_ONBOARDING_LIVE_DATE)
  end
end
