# frozen_string_literal: true

module External::StripeApi
  SUBSCRIPTION_NOT_FOUND = 'No such subscription'
  COUPON_NOT_FOUND = 'No such coupon'
  PLAN_NOT_FOUND = 'No such plan'
  INVOICE_NOT_FOUND = 'No such invoice'

  extend self

  def create_coupon(code:, name: nil, percent_off:)
    Stripe::Coupon.retrieve(code)
  rescue Stripe::InvalidRequestError => e
    return Stripe::Coupon.create(percent_off: percent_off, duration: 'forever', id: code, name: name) if e.message.include? COUPON_NOT_FOUND

    raise
  end

  def subscription_url(stripe_subscription_id)
    resource_url(resource_name: 'subscription', resource_id: stripe_subscription_id)
  end

  def coupon_url(stripe_coupon_code)
    resource_url(resource_name: 'coupon', resource_id: stripe_coupon_code)
  end

  def customer_url(stripe_customer_id)
    resource_url(resource_name: 'customer', resource_id: stripe_customer_id)
  end

  def plan_url(stripe_plan_id)
    resource_url(resource_name: 'plan', resource_id: stripe_plan_id)
  end

  def destroy_coupon(code:)
    coupon = Stripe::Coupon.retrieve(code)
    coupon.delete
  rescue Stripe::InvalidRequestError
    false
  end

  def create_customer(email:, description: nil, metadata: nil, extra: {}, stripe_token_id: nil)
    extra = extra.to_h

    Stripe::Customer.create(
      source: stripe_token_id,
      payment_method: extra[:payment_method],
      email: email,
      description: description,
      metadata: metadata,
      address: parse_address(extra[:address]),
      name: extra[:name],
      phone: extra[:phone],
      invoice_settings: { custom_fields: parse_custom_fields(extra[:invoice]) },
    )
  end

  def create_subscription(customer:, items:, payment_behavior: nil, expand: nil, coupon: nil, metadata: nil)
    Stripe::Subscription.create(
      customer: customer,
      items: items,
      coupon: coupon,
      metadata: metadata,
      payment_behavior: payment_behavior,
      expand: expand, # Note(Bharat): This `expand` key is not present in stripe:subscriptions api but can be found here - https://stripe.com/docs/api/expanding_objects
    )
  end

  def retrieve_subscription(stripe_subscription_id:)
    Stripe::Subscription.retrieve(stripe_subscription_id)
  end

  # (nvalchanov): Docs https://stripe.com/docs/api/subscriptions/cancel
  def cancel_subscription_immediately(subscription_id)
    Stripe::Subscription.delete(subscription_id)
  end

  def cancel_subscription(subscription_id:, reason: nil)
    subscription = Stripe::Subscription.retrieve(subscription_id)
    subscription.cancel_at_period_end = true
    subscription.metadata = { cancellation_reason: reason } if reason.present?
    subscription.save
  end

  def refund_subscription(subscription_id:, reason: nil, till_the_end_of_the_billing_period: true)
    subscription = Stripe::Subscription.retrieve(subscription_id)
    latest_invoice_id = subscription['latest_invoice']
    return if latest_invoice_id.blank?

    invoice = Stripe::Invoice.retrieve(latest_invoice_id)
    charge = invoice['charge']
    return if charge.blank?

    refund = Stripe::Refund.create(charge: charge, metadata: { refund_reason: reason })

    if till_the_end_of_the_billing_period
      subscription.cancel_at_period_end = true
      subscription.save
    else
      Stripe::Subscription.delete(subscription_id)
    end

    refund
  end

  def fetch_plan(plan_id)
    Stripe::Plan.retrieve(plan_id)
  rescue Stripe::InvalidRequestError => e
    return if e.message.include? PLAN_NOT_FOUND

    raise
  end

  def fetch_invoice(invoice_id)
    Stripe::Invoice.retrieve(invoice_id)
  rescue Stripe::InvalidRequestError => e
    return if e.message.include? INVOICE_NOT_FOUND

    raise
  end

  def delete_card(customer_id, card_id)
    Stripe::Customer.delete_source(customer_id, card_id)
  end

  def create_card(customer_id, token_id)
    Stripe::Customer.create_source(customer_id, source: token_id)
  end

  def fetch_customer_card(customer_id)
    Stripe::Customer.list_sources(customer_id, object: 'card', limit: 1).data.first
  end

  private

  def resource_url(resource_name:, resource_id:)
    "https://dashboard.stripe.com/#{ Rails.env.production? ? '' : 'test/' }#{ resource_name.pluralize }/#{ resource_id }"
  end

  def parse_address(address)
    return if address.nil?

    address.each { |k, v| address.delete(k) if v.empty? }
  end

  def parse_custom_fields(invoice)
    return if invoice.nil?

    invoice.map(&:to_a).flatten(1).each_with_object([]) { |(k, v), result| result << { name: k, value: v } if v.present? }
  end
end
