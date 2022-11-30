# frozen_string_literal: true

module Ships
  module Payments
    module Subscription
      extend self

      PLANS = {
        pro: {
          monthly: 'pro_monthly',
          annual: 'pro_yearly',
        },
        super_pro: {
          monthly: 'super_pro_monthly',
          annual: 'super_pro_yearly',
        },
      }.freeze

      def sync!(ship_subscription)
        # NOTE(vesln): we have no billing info for the user, which means that
        # the user has a FREE premium subscription (friend of PH)
        return :no_billing_info if ship_subscription.ship_billing_information.blank?

        # NOTE(vesln): there is already a subscription in Stripe
        return :already_exists if ship_subscription.stripe_subscription_id?

        billing_info = ship_subscription.ship_billing_information

        raise "User #{ billing_info.user_id } already has active subscription(s)!" unless list_active_subscriptions(billing_info).empty?

        create!(ship_subscription)
      end

      def create_or_update!(ship_subscription)
        billing_info = ship_subscription.ship_billing_information

        stripe_subscriptions = list_active_subscriptions(billing_info)

        if stripe_subscriptions.empty? # NOTE(vesln): new subscription
          create!(ship_subscription)
        elsif stripe_subscriptions.size == 1 # NOTE(vesln): existing subscription
          update!(ship_subscription, stripe_subscriptions.first)
        else # NOTE(vesln): User has more than 1 active subscriptions, should never happen
          raise "User #{ ship_subscription.user_id } has #{ stripe_subscriptions.size } active subscriptions!"
        end
      end

      def create!(ship_subscription)
        billing_info = ship_subscription.ship_billing_information

        params = {
          customer: billing_info.stripe_customer_id,
          coupon: find_coupon_id(billing_info),
          items: [
            {
              plan: find_stripe_plan_id(ship_subscription),
            },
          ],
        }

        stripe_subscription = Stripe::Subscription.create(params)

        ship_subscription.update!(stripe_subscription_id: stripe_subscription.id)
      end

      def update!(ship_subscription, stripe_subscription)
        items = [{
          id: stripe_subscription.items.data[0].id,
          plan: find_stripe_plan_id(ship_subscription),
        }]

        stripe_subscription.items = items
        stripe_subscription.save

        ship_subscription.update!(stripe_subscription_id: stripe_subscription.id)
      end

      def update_coupon!(ship_subscription)
        billing_info = ship_subscription.ship_billing_information

        stripe_subscription = Stripe::Subscription.retrieve(ship_subscription.stripe_subscription_id)
        stripe_subscription.coupon = find_coupon_id(billing_info)
        stripe_subscription.save
      end

      def cancel!(ship_subscription, at_period_end:, till_the_end_of_the_billing_period:)
        # NOTE(vesln): we have no billing info for the user, which means that
        # the user has a FREE subscription
        return :no_billing_info if ship_subscription.ship_billing_information.blank?

        # NOTE(vesln): there is no subscription in Stripe, nothing to do
        return :stripe_blank if ship_subscription.stripe_subscription_id.blank?

        subscription = Stripe::Subscription.retrieve(ship_subscription.stripe_subscription_id)

        if till_the_end_of_the_billing_period
          subscription.delete(at_period_end: at_period_end)
        else
          External::StripeApi.cancel_subscription_immediately(subscription.id)
        end

        subscription
      end

      def list_active_subscriptions(ship_billing_information)
        Stripe::Subscription.list(
          status: 'active',
          customer: ship_billing_information.stripe_customer_id,
        ).data
      end

      def find_stripe_plan_id(ship_subscription)
        plan_id = PLANS.dig(ship_subscription.billing_plan.to_sym, ship_subscription.billing_period.to_sym)

        if plan_id.blank?
          ErrorReporting.report_error_message(
            'Unable to find a ship plan ID for ship subscription',
            extra: {
              billing_plan: ship_subscription.billing_plan,
              billing_info: ship_subscription.ship_billing_information,
              ship_subscription_id: ship_subscription.id,
            },
          )
        end

        plan_id
      end

      def find_coupon_id(ship_billing_information)
        invite = ship_billing_information.ship_invite_code

        return if invite.blank?
        return unless invite.discount?

        invite.code
      end
    end
  end
end
