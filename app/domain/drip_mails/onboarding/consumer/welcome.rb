# frozen_string_literal: true

module DripMails::Onboarding::Consumer::Welcome
  extend self

  def call(drip_mail)
    user = drip_mail.user
    return unless DripMails::Onboarding.new(user: user).can_receive_onboarding_email?

    user.update! welcome_email_sent: true
    DripMails::Onboarding::ConsumerOnboardingMailer.initial_welcome(user).deliver_now
  end
end
