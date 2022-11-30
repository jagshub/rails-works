# frozen_string_literal: true

class Ships::Slack::Subscription
  class << self
    def call(ship_subscription: nil, previous_ship_subscription: nil)
      if previous_ship_subscription.present?
        Ships::Slack::SubscriptionPlanChange.call(
          ship_subscription: ship_subscription,
          previous_ship_subscription: previous_ship_subscription,
        )
      else
        Ships::Slack::NewSubscription.call(ship_subscription: ship_subscription)
      end
    end
  end
end
