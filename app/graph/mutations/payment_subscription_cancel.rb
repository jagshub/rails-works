# frozen_string_literal: true

module Graph::Mutations
  class PaymentSubscriptionCancel < BaseMutation
    argument :plan_id, ID, required: true
    argument :reason, String, required: false

    require_current_user

    def perform(plan_id:, reason: nil)
      ::Payments::HandleError.call(current_user_id: current_user.id) do
        ::Payments::CancelSubscription.call(
          user: current_user,
          plan_id: plan_id,
          reason: reason,
        )
        success
      end
    end
  end
end
