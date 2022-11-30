# frozen_string_literal: true

module Mobile::Graph::Mutations
  class CollectionUnfollow < BaseMutation
    argument_record :collection, Collection, required: true

    require_current_user

    returns Mobile::Graph::Types::CollectionType

    def perform(collection:)
      CollectionSubscription.unsubscribe(collection, user: current_user)
      collection.reload
    end
  end
end
