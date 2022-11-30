# frozen_string_literal: true

module API::V2Internal::Mutations
  class CollectionRemovePost < BaseMutation
    argument :post_id, ID, required: true, camelize: false

    node :collection, type: Collection

    authorize :update

    returns API::V2Internal::Types::CollectionPostType

    def perform
      collection_post = node.collection_post_associations.find_by(post_id: inputs[:post_id])

      Collections.remove(collection_post.collection, collection_post.post)

      collection_post
    end
  end
end
