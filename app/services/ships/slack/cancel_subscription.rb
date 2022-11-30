# frozen_string_literal: true

class Ships::Slack::CancelSubscription < Ships::Slack::SubscriptionNotification
  attr_reader :ship_subscription, :moderator, :reason

  class << self
    def call(ship_subscription:, moderator:, reason: nil)
      new(ship_subscription, moderator, reason).deliver
    end
  end

  def initialize(ship_subscription, moderator, reason)
    @moderator = moderator
    @ship_subscription = ship_subscription
    @reason = reason
  end

  private

  def channel
    'ship_activity'
  end

  def author
    ship_subscription.user
  end

  def title
    "#{ author_name }'s subscription has been cancelled"
  end

  def title_link
    'https://www.producthunt.com/admin/ship_subscriptions'
  end

  def fields
    fields = []

    if moderator.present?
      moderator_name = "#{ moderator.name } (@#{ moderator.username })"
      fields << { title: 'Moderator', value: moderator_name, short: true }
    end

    fields << { title: 'Reason', value: reason, short: true } if reason.present?

    fields + super
  end

  def icon_emoji
    ':red_circle:'
  end

  def color
    '#980000'
  end
end
