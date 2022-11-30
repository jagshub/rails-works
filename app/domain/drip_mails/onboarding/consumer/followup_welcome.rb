# frozen_string_literal: true

module DripMails::Onboarding::Consumer::FollowupWelcome
  extend self

  def call(drip_mail)
    user = drip_mail.user
    return unless DripMails::Onboarding.new(user: user).can_receive_onboarding_email?

    DripMails::Onboarding::ConsumerOnboardingMailer.followup_welcome(user).deliver_now
  end
end
