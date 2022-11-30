# frozen_string_literal: true

module DripMails::Onboarding::Maker::AdditionalResources
  extend self

  def call(drip_mail)
    user = drip_mail.user
    return unless DripMails::Onboarding.new(user: user).can_receive_onboarding_email?
    return unless user.posts_count.zero?

    DripMails::Onboarding::MakerOnboardingMailer.additional_maker_resources(user).deliver_now
  end
end
