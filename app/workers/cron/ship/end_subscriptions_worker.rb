# frozen_string_literal: true

class Cron::Ship::EndSubscriptionsWorker < ApplicationJob
  def perform
    ShipSubscription.includes(:user).ended.find_each do |subscription|
      Ships::EndSubscriptionWorker.perform_later(subscription.user)
    end

    Ships::DowngradeExpiredTrials.call
  end
end
