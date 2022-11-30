# frozen_string_literal: true

module Graph::Mutations
  class CollectionDestroy < BaseMutation
    argument_record :collection, Collection, authorize: :destroy

    returns Graph::Types::CollectionType

    def perform(collection:)
      collection.destroy!
      collection
    end
  end
end
