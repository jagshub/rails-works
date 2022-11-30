# frozen_string_literal: true

module Mobile::Graph::Mutations
  class CollectionProductSet < BaseMutation
    argument_record :product, Product
    argument_records :collections, Collection, authorize: :update

    require_current_user

    returns Mobile::Graph::Types::ProductType

    def perform(collections:, product:)
      Collections.set_product collections: collections, product: product, current_user: current_user
    end
  end
end
