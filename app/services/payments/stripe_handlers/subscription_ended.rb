# frozen_string_literal: true

module Payments::StripeHandlers::SubscriptionEnded
  extend self

  def call(subscription)
    return if subscription.nil?
    return if subscription.expired?

    subscription.update!(stripe_canceled_at: Time.zone.now, expired_at: Time.zone.now)
    PaymentsMailer.subscription_canceled_by_stripe(subscription).deliver_later unless subscription.canceled?
  end
end
