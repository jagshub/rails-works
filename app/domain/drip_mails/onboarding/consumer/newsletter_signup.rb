# frozen_string_literal: true

module DripMails::Onboarding::Consumer::NewsletterSignup
  extend self

  def call(drip_mail)
    user = drip_mail.user
    return unless DripMails::Onboarding.new(user: user).can_receive_onboarding_email?
    return if Newsletter::Subscriptions.active?(user: user, email: user.email, subscriber: user.subscriber)

    DripMails::Onboarding::ConsumerOnboardingMailer.newsletter_signup_cta(user).deliver_now
  end
end
