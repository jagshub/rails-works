# frozen_string_literal: true

module Graph::Mutations
  class CollectionCreateWithProduct < BaseMutation
    argument :name, String, required: true
    argument_record :product, Product

    returns Graph::Types::CollectionType

    require_current_user

    def perform(name:, product:)
      collection = HandleRaceCondition.call do
        current_user.collections.find_or_create_by!(name: name&.strip)
      end

      Collections.add(collection, product)

      collection
    end
  end
end
