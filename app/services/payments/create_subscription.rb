# frozen_string_literal: true

module Payments::CreateSubscription
  extend self
  def call(user:, subscription_id:, discount_code: nil, marketing_campaign_name: nil)
    stripe_subscription = ::External::StripeApi.retrieve_subscription(stripe_subscription_id: subscription_id)
    raise Payments::Errors::InvalidSubscriptionIdError if stripe_subscription.nil?

    plan_id = stripe_subscription.metadata.plan_id
    plan = find_plan(plan_id)

    project = plan.project
    discount = plan.discounts.active.find_by_code(discount_code)
    coupon_code = discount&.stripe_coupon_code

    subscription = Payment::Subscription.create!(
      user_id: user.id,
      plan_id: plan.id,
      discount_id: discount&.id,
      project: project,
      plan_amount_in_cents: plan.amount_in_cents,
      charged_amount_in_cents: charged_amount_in_cents(plan: plan, discount: discount),
      stripe_customer_id: stripe_subscription.customer,
      stripe_subscription_id: subscription_id,
      stripe_coupon_code: coupon_code,
      marketing_campaign_name: marketing_campaign_name,
    )

    PaymentsMailer.subscription_created(subscription).deliver_later

    FounderClub.handle_subscription(subscription)

    subscription
  end

  private

  def find_plan(plan_id)
    plan = Payment::Plan.active.find_by(id: plan_id)
    raise Payments::Errors::InvalidPlanError if plan.nil?

    plan
  end

  def charged_amount_in_cents(plan:, discount:)
    discount_percentage = discount&.percentage_off || 0
    (plan.amount_in_cents * (1 - discount_percentage / 100.to_f)).round
  end
end
