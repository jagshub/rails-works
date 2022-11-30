# frozen_string_literal: true

class Ships::Slack::NewSubscription < Ships::Slack::SubscriptionNotification
  attr_reader :ship_subscription

  class << self
    def call(ship_subscription:)
      new(ship_subscription).deliver
    end
  end

  def initialize(ship_subscription)
    @ship_subscription = ship_subscription
  end

  private

  def channel
    'ship_activity'
  end

  def author
    ship_subscription.user
  end

  def title
    plan = ship_subscription.trial? ? "trial (#{ ship_subscription.billing_plan })" : "#{ ship_subscription.billing_plan }/#{ ship_subscription.billing_period }"

    "#{ author_name } signed up for #{ plan }"
  end

  def title_link
    "https://www.producthunt.com/admin/ship_subscriptions/#{ ship_subscription.id }"
  end

  def icon_emoji
    ship_subscription.trial? ? ':simple_smile:' : ':money_mouth_face:'
  end

  def color
    ship_subscription.trial? ? '#d8c7a6' : '#66be00'
  end
end
