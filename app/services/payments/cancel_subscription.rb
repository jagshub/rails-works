# frozen_string_literal: true

module Payments::CancelSubscription
  DEFAULT_REASON = 'User canceled subscription'
  NOT_FOUND_REASON = 'Subscription did not exist in Stripe'

  extend self

  def call(user:, plan_id:, reason: DEFAULT_REASON)
    active_subscriptions = ::Payment::Subscription.active_for_user_in_plan(user: user, plan: plan_id).to_a
    return if active_subscriptions.empty?

    raise Payments::Errors::MultipleActiveSubscriptionsForPlanError if active_subscriptions.size > 1

    subscription_to_cancel = active_subscriptions.first
    return if subscription_to_cancel.canceled?

    External::StripeApi.cancel_subscription(subscription_id: subscription_to_cancel.stripe_subscription_id)
    subscription_to_cancel.update!(user_canceled_at: Time.zone.now, cancellation_reason: reason)

    PaymentsMailer.subscription_canceled_by_user(subscription_to_cancel).deliver_later
  rescue Stripe::InvalidRequestError => e
    raise unless e.message.include? External::StripeApi::SUBSCRIPTION_NOT_FOUND

    ErrorReporting.report_error(e, extra: { subscription_id: subscription_to_cancel.id, stripe_subscription_id: subscription_to_cancel.stripe_subscription_id })
    subscription_to_cancel.update!(user_canceled_at: Time.zone.now, stripe_canceled_at: Time.zone.now, expired_at: Time.zone.now, cancellation_reason: NOT_FOUND_REASON)
  end
end
