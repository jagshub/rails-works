# frozen_string_literal: true

module Graph::Mutations
  class CollectionFollow < BaseMutation
    argument_record :collection, Collection, required: true

    require_current_user

    returns Graph::Types::CollectionType

    def perform(collection:)
      CollectionSubscription.subscribe(collection, user: current_user)
      collection
    end
  end
end
