# frozen_string_literal: true

class WebHooks::StripeWorker
  include Sidekiq::Worker

  CHARGE_FAILED = 'charge.failed'
  CHARGE_TYPE = 'charge'
  CHARGE_REFUNDED = 'charge.refunded'
  INVOICE_UPCOMING = 'invoice.upcoming'
  INVOICE_PAYMENT_SUCCEEDED = 'invoice.payment_succeeded'
  SUBSCRIPTION_ENDED = 'customer.subscription.deleted'

  HANDLERS = [
    Ships::HandleStripeWebhook,
    Jobs::HandleStripeWebhook,
    Payments::HandleStripeWebhook,
    # NOTE(rstankov): Webhook doesnt deal with charges
    ->(payload) { payload['data']['object']['object'] == CHARGE_TYPE },
  ].freeze

  def perform(payload = {})
    return if HANDLERS.find { |handler| handler.call(payload) }

    ErrorReporting.report_error_message(
      'Unable to find a Stripe customer with ID',
      extra: {
        customer: payload['data']['object']['customer'],
        type: payload['type'],
        object: payload['data']['object']['object'],
      },
    )
  end
end
