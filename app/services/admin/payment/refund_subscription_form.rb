# frozen_string_literal: true

class Admin::Payment::RefundSubscriptionForm
  include MiniForm::Model

  STRIPE_REFUND_ERROR = 'Creating refund on Stripe failed'
  STRIPE_INVOICE_OR_CHARGE_NOT_FOUND_ERROR = 'Could not find Invoice or Charge for subscription on Stripe'

  SUBSCRIPTION_ATTRIBUTES = %i(refunded_at stripe_refund_id refund_reason stripe_subscription_id).freeze

  model :payment_subscription, attributes: SUBSCRIPTION_ATTRIBUTES, save: true

  attributes :till_the_end_of_the_billing_period

  delegate :id, :refunded?, :stripe_subscription_id_changed?, to: :payment_subscription

  before_validation :create_refund_on_stripe

  def initialize(payment_subscription = nil, till_the_end_of_the_billing_period = true)
    @payment_subscription = payment_subscription
    @till_the_end_of_the_billing_period = till_the_end_of_the_billing_period
  end

  def to_model
    payment_subscription
  end

  private

  def create_refund_on_stripe
    return errors.add(:refund_reason, 'cannot be empty') if refund_reason.blank?
    return errors.add(:stripe_subscription_id, 'invalid for subscription') if stripe_subscription_id_changed?

    refund = External::StripeApi.refund_subscription(subscription_id: stripe_subscription_id, reason: refund_reason, till_the_end_of_the_billing_period: @till_the_end_of_the_billing_period)
    return errors.add :subscription, STRIPE_INVOICE_OR_CHARGE_NOT_FOUND_ERROR if refund.nil?

    self.stripe_refund_id = refund.id
    self.refunded_at = Time.zone.now
  rescue StandardError => e
    ErrorReporting.report_error(e)
    errors.add :network, STRIPE_REFUND_ERROR
  end
end
