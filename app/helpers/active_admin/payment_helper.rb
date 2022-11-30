# frozen_string_literal: true

module ActiveAdmin::PaymentHelper
  def payment_subscription_status(subscription)
    status = "Refunded initiated on #{ subscription.refunded_at.strftime('%B %d, %Y') } " if subscription.refunded?
    status = "Ended on #{ subscription.ended_on.strftime('%B %d, %Y') }" if subscription.ended_on.present?
    status = "User Canceled on #{ subscription.user_canceled_at.strftime('%B %d, %Y') }" if subscription.user_canceled_at

    status || "Active since #{ subscription.created_at.strftime('%B %d, %Y') } "
  end
end
