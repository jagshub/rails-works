# frozen_string_literal: true

module API::V2Internal::Mutations
  class CollectionAddPost < BaseMutation
    argument :post_id, ID, required: true, camelize: false

    node :collection, type: Collection

    authorize :update

    returns API::V2Internal::Types::CollectionPostType

    def perform
      post = Post.find inputs[:post_id]

      Collections.add(node, post)[:post_association]
    end
  end
end
