# frozen_string_literal: true

module Graph::Mutations
  class ShipAccountUpdate < BaseMutation
    argument_record :account, ShipAccount, required: true, authorize: ApplicationPolicy::MAINTAIN
    argument :name, String, required: false
    argument :member_ids, [ID], required: false

    returns Graph::Types::ShipAccountType

    def perform(account:, name: nil, member_ids: nil)
      account.update(name: name, member_ids: member_ids)
      account
    end
  end
end
