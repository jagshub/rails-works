# frozen_string_literal: true

module Payments::HandleStripeWebhook
  extend self

  def call(payload)
    event_type = payload['type']
    stripe_customer_id = payload['data']['object']['customer']
    stripe_invoice_id = payload['data']['object']['invoice']
    stripe_subscription_id = payload['data']['object']['subscription']

    subscription = ::Payment::Subscription.find_by(stripe_customer_id: stripe_customer_id, stripe_subscription_id: stripe_subscription_id)

    if subscription.present?
      handle_subscription_events(event_type, subscription)
    elsif stripe_invoice_id.present? && event_type == WebHooks::StripeWorker::CHARGE_REFUNDED
      Payments::StripeHandlers::ChargeRefunded.call(stripe_invoice_id: stripe_invoice_id, stripe_customer_id: stripe_customer_id)
      true
    else
      false
    end
  end

  private

  def handle_subscription_events(event_type, subscription)
    case event_type
    when WebHooks::StripeWorker::INVOICE_UPCOMING then Payments::StripeHandlers::InvoiceUpcoming.call(subscription)
    when WebHooks::StripeWorker::SUBSCRIPTION_ENDED then Payments::StripeHandlers::SubscriptionEnded.call(subscription)
    else ErrorReporting.report_error_message("Unknown payload type - '#{ payload['type'] }' for Payments Subscription")
    end

    true
  end
end
