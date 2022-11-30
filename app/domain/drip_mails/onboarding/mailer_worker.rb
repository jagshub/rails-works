# frozen_string_literal: true

class DripMails::Onboarding::MailerWorker < ApplicationJob
  queue_as :mailers

  def perform(user)
    DripMails.begin_onboarding_drip(user: user)
  end
end
