# frozen_string_literal: true

module Graph::Mutations
  class ShipContactDestroy < BaseMutation
    argument_record :contact, ShipContact, required: true, authorize: ApplicationPolicy::MAINTAIN

    returns Graph::Types::ShipContactType

    def perform(contact:)
      contact.trash
      contact
    end
  end
end
