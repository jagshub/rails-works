# frozen_string_literal: true

class Ships::Slack::SubscriptionPlanChange < Ships::Slack::SubscriptionNotification
  attr_reader :ship_subscription, :previous_ship_subscription

  class << self
    def call(ship_subscription:, previous_ship_subscription:)
      new(ship_subscription, previous_ship_subscription).deliver
    end
  end

  def initialize(ship_subscription, previous_ship_subscription)
    @ship_subscription = ship_subscription
    @previous_ship_subscription = previous_ship_subscription
  end

  private

  def channel
    'ship_activity'
  end

  def author
    ship_subscription.user
  end

  def title
    new_plan = "#{ ship_subscription.billing_plan }/#{ ship_subscription.billing_period }"

    old_plan = if previous_ship_subscription.trial?
                 'trial'
               else
                 "#{ previous_ship_subscription.billing_plan }/#{ previous_ship_subscription.billing_period }"
               end

    "#{ author_name } changed their subscription from #{ old_plan } to #{ new_plan }"
  end

  def title_link
    'https://www.producthunt.com/admin/ship_subscriptions'
  end

  def icon_emoji
    ':money_mouth_face:'
  end

  def color
    '#66be00'
  end
end
