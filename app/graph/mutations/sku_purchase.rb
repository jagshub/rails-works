# frozen_string_literal: true

module Graph::Mutations
  class SkuPurchase < BaseMutation
    argument :stripe_token_id, String, required: true
    argument :billing_email, String, required: true
    argument :checkout_page_id, ID, required: true
    argument :extra, Graph::Types::PaymentExtraInputType, required: false

    require_current_user

    returns Graph::Types::CheckoutPageType

    def perform(inputs)
      ::Payments::HandleError.call(current_user_id: current_user.id) do
        CheckoutPages::Purchase.call(inputs: inputs, user: current_user)
      end
    end
  end
end
