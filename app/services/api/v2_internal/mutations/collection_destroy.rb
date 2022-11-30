# frozen_string_literal: true

module API::V2Internal::Mutations
  class CollectionDestroy < BaseMutation
    node :collection, type: ::Collection

    authorize :destroy

    returns API::V2Internal::Types::CollectionType

    def perform
      node.destroy
      node
    end
  end
end
