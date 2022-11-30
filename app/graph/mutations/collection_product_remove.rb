# frozen_string_literal: true

module Graph::Mutations
  class CollectionProductRemove < BaseMutation
    argument_record :collection, Collection, authorize: :update
    argument_record :product, Product

    returns Graph::Types::CollectionType
    field :product, Graph::Types::ProductType, null: false

    def perform(collection:, product:)
      Collections.remove(collection, product)

      {
        node: collection,
        product: product,
      }
    end
  end
end
