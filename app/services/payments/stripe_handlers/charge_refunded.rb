# frozen_string_literal: true

module Payments::StripeHandlers::ChargeRefunded
  extend self

  def call(stripe_invoice_id:, stripe_customer_id:)
    invoice = External::StripeApi.fetch_invoice(stripe_invoice_id)
    return if invoice.nil?

    subscription = ::Payment::Subscription.find_by(stripe_customer_id: stripe_customer_id, stripe_subscription_id: invoice['subscription'])
    subscription.expire if subscription.present?
  rescue StandardError => e
    ErrorReporting.report_error(e)
  end
end
