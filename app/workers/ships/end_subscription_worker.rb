# frozen_string_literal: true

class Ships::EndSubscriptionWorker < ApplicationJob
  def perform(user)
    return unless user.ship_subscription&.ended?

    Ships::DowngradeSubscription.call(user)
  end
end
