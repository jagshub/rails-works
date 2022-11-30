# frozen_string_literal: true

module Jobs::HandleStripeWebhook
  extend self

  def call(payload)
    stripe_customer_id = payload['data']['object']['customer']
    jobs = Job.where(stripe_customer_id: stripe_customer_id)

    return false unless jobs.exists?

    case payload['type']
    when WebHooks::StripeWorker::INVOICE_PAYMENT_SUCCEEDED
      then handle_payment_succeed(jobs)
    when
      WebHooks::StripeWorker::SUBSCRIPTION_ENDED,
      WebHooks::StripeWorker::CHARGE_REFUNDED,
      WebHooks::StripeWorker::CHARGE_FAILED
      then handle_downgrade_payloads(jobs)
    else
      return false
    end

    true
  end

  private

  def handle_payment_succeed(jobs)
    jobs.each { |job| Jobs::Renewal.call(job) }
  end

  def handle_downgrade_payloads(jobs)
    jobs.each { |job| Jobs::Downgrade.call(job) }
  end
end
