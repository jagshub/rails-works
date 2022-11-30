# frozen_string_literal: true

module Graph::Mutations
  class ShipSubscriptionCancel < BaseMutation
    argument :reason, String, required: false
    argument :remove_upcoming_pages, Boolean, required: false

    returns Graph::Types::ShipSubscriptionType

    require_current_user

    def perform(inputs)
      return error :ship_subscription, :blank if current_user.ship_subscription.blank?
      return error :reason, :blank if inputs[:reason].blank?

      Ships::CancelSubscription.call(
        user: current_user,
        reason: inputs[:reason],
        trash_upcoming_pages: !!inputs[:remove_upcoming_pages],
      )

      current_user.ship_subscription
    end
  end
end
