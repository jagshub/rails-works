# frozen_string_literal: true

module Graph::Mutations
  class ShipStripeDiscountRequest < BaseMutation
    argument_record :account, ShipAccount, required: true, authorize: ApplicationPolicy::MAINTAIN

    def perform(account:)
      Ships::StripeDiscountCode.deliver_to(account)
      success
    end
  end
end
