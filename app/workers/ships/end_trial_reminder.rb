# frozen_string_literal: true

class Ships::EndTrialReminder < ApplicationJob
  include ActiveJobHandleMailjetErrors

  def perform(account)
    return unless account.trial?

    ShipMailer.trial_expired(account).deliver_now
  end
end
