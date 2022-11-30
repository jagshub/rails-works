# frozen_string_literal: true

module Ships::HandleStripeWebhook
  extend self

  def call(payload)
    stripe_customer_id = payload['data']['object']['customer']
    billing_info = ShipBillingInformation.find_by(stripe_customer_id: stripe_customer_id)

    return false if billing_info.nil?

    case payload['type']
    when WebHooks::StripeWorker::SUBSCRIPTION_ENDED, WebHooks::StripeWorker::CHARGE_REFUNDED then Ships::DowngradeSubscription.call(billing_info.user)
    when WebHooks::StripeWorker::CHARGE_FAILED then Ships::HandleFailedCharge.call(billing_info.user)
    else ErrorReporting.report_error_message("Unknown payload type - '#{ payload['type'] }' for Ship Subscriptions")
    end

    true
  end
end
