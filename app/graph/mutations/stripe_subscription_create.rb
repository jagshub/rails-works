# frozen_string_literal: true

module Graph::Mutations
  class StripeSubscriptionCreate < BaseMutation
    argument :plan_id, String, required: true
    argument :customer_email, String, required: true
    argument :extra, Graph::Types::PaymentExtraInputType, required: false
    argument :discount_code, String, required: false

    require_current_user

    returns Graph::Types::Stripe::PaymentIntentType

    def perform(plan_id:, customer_email:, extra: {}, discount_code: nil)
      return if current_user.blank?

      ::Payments::HandleError.call(current_user_id: current_user.id) do
        plan = find_plan(plan_id)
        project = plan.project

        active_subscription_for_plan = ::Payment::Subscription.active_for_user_in_plan(user: current_user, plan: plan_id).first
        raise Payments::Errors::HasActiveSubscriptionInProjectError if active_subscription_for_plan.present?

        handle_active_subscription_in_project(user: current_user, project: plan.project)

        customer = ::External::StripeApi.create_customer(
          email: customer_email || current_user.email,
          description: current_user.id.to_s,
          metadata: { project: project, user_id: current_user.id },
          extra: extra.to_h,
        )

        discount = plan.discounts.active.find_by_code(discount_code)
        coupon_code = discount&.stripe_coupon_code

        subscription = ::External::StripeApi.create_subscription(
          customer: customer.id,
          coupon: coupon_code,
          items: [{ plan: plan.stripe_plan_id }],
          metadata: { project: project, plan_id: plan_id },
          payment_behavior: 'default_incomplete',
          expand: ['latest_invoice.payment_intent'],
        )

        OpenStruct.new(subscription_id: subscription.id, client_secret: subscription.latest_invoice.payment_intent.client_secret, customer_id: customer.id)
      end
    end

    private

    def find_plan(plan_id)
      plan = Payment::Plan.active.find_by(id: plan_id)
      raise Payments::Errors::InvalidPlanError if plan.nil?

      plan
    end

    def handle_active_subscription_in_project(user:, project:)
      active_subscriptions_in_project = ::Payment::Subscription.active_for_user_in_project(user: user, project: project).to_a
      raise Payments::Errors::HasActiveSubscriptionInProjectError unless active_subscriptions_in_project.empty?
    end
  end
end
