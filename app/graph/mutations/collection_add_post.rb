# frozen_string_literal: true

module Graph::Mutations
  class CollectionAddPost < BaseMutation
    argument_record :collection, Collection, authorize: :update
    argument_record :post, -> { Post.visible }

    returns Graph::Types::CollectionPostType

    def perform(collection:, post:)
      Collections.add(collection, post)[:post_association]
    end
  end
end
