# frozen_string_literal: true

module Graph::Resolvers
  class Ships::BillingResolver < Graph::Resolvers::Base
    type Graph::Types::ShipType, null: true

    def self.build(&block)
      resolver_class = Class.new(self)
      resolver_class.define_method(:fetch_user) { block.call(object) } if block.present?

      resolver_class
    end

    def resolve
      user = fetch_user
      return if user.nil?
      return if object && object != :viewer && !ApplicationPolicy.can?(current_user, ApplicationPolicy::MAINTAIN, object)

      subscription = user.ship_subscription || ShipSubscription.new(billing_plan: :free)

      OpenStruct.new(
        billing_plan: billing_plan_for(subscription),
        billing_period: subscription.billing_period,
        cancelled_billing_plan: cancelled_billing_plan_for(subscription),
        ends_at: subscription.trial? ? subscription.trial_ends_at : subscription.ends_at,
        ended: subscription.ended?,
        discount: discount_for(user),
        trial_ended: subscription.trial_ended?,
        in_trial: subscription.trial?,
      )
    end

    def fetch_user
      # just give back current user if no block provided
      current_user
    end

    private

    def discount_for(user)
      ::Ships::InviteCode.call(user)&.discount_value
    end

    def cancelled_billing_plan_for(subscription)
      subscription.billing_plan if subscription.cancelled? || subscription.ended?
    end

    def billing_plan_for(subscription)
      if subscription.trial? && subscription.trial_ended?
        nil
      elsif subscription.ended?
        :free
      else
        subscription.billing_plan
      end
    end
  end
end
