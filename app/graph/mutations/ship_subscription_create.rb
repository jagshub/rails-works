# frozen_string_literal: true

module Graph::Mutations
  class ShipSubscriptionCreate < BaseMutation
    argument :stripe_token_id, String, required: false
    argument :ship_instant_access_page_id, ID, required: false
    argument :billing_email, String, required: false
    argument :billing_plan, String, required: true
    argument :billing_period, String, required: true
    argument :extra, Graph::Types::PaymentExtraInputType, required: false

    require_current_user

    returns Graph::Types::ShipSubscriptionType

    def perform(inputs)
      ::Payments::HandleError.call(current_user_id: current_user.id) do
        ::Ships::CreateSubscription.call(inputs: inputs, current_user: current_user)
      end
    end
  end
end
