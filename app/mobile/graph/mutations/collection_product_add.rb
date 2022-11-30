# frozen_string_literal: true

module Mobile::Graph::Mutations
  class CollectionProductAdd < BaseMutation
    argument_record :collection, Collection, authorize: :update
    argument_record :product, Product

    returns Mobile::Graph::Types::CollectionType

    def perform(collection:, product:)
      Collections.add(collection, product)
      collection
    end
  end
end
