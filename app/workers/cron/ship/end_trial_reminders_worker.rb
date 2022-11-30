# frozen_string_literal: true

class Cron::Ship::EndTrialRemindersWorker < ApplicationJob
  def perform
    ShipSubscription.includes(:account).ended_trial.find_each do |subscription|
      Ships::EndTrialReminder.perform_later(subscription.account)
    end
  end
end
