# frozen_string_literal: true

module Graph::Mutations
  class PaymentSubscriptionCreate < BaseMutation
    argument :stripe_subscription_id, String, required: true
    argument :discount_code, String, required: false

    require_current_user

    returns Graph::Types::Payment::SubscriptionType

    def perform(stripe_subscription_id:, discount_code: nil)
      ::Payments::HandleError.call(current_user_id: current_user.id) do
        ::Payments::CreateSubscription.call(
          user: current_user,
          subscription_id: stripe_subscription_id,
          discount_code: discount_code,
          marketing_campaign_name: context[:cookies][:first_campaign],
        )
      end
    end
  end
end
