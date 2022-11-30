# frozen_string_literal: true

module Mobile::Graph::Mutations
  class CollectionDestroy < BaseMutation
    argument_record :collection, Collection, authorize: :destroy

    returns Mobile::Graph::Types::CollectionType

    def perform(collection:)
      collection.destroy!
      collection
    end
  end
end
