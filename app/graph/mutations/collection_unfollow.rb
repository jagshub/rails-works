# frozen_string_literal: true

module Graph::Mutations
  class CollectionUnfollow < BaseMutation
    argument_record :collection, Collection, required: true

    require_current_user

    returns Graph::Types::CollectionType

    def perform(collection:)
      CollectionSubscription.unsubscribe(collection, user: current_user)
      collection.reload
    end
  end
end
