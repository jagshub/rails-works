# frozen_string_literal: true

module Mobile::Graph::Mutations
  class CollectionPostSet < BaseMutation
    argument_record :post, Post
    argument_records :collections, Collection, authorize: :update

    require_current_user

    returns Mobile::Graph::Types::PostType

    def perform(collections:, post:)
      Collections.set_post collections: collections, post: post, current_user: current_user
    end
  end
end
