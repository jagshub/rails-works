# frozen_string_literal: true

module Graph::Mutations
  class CollectionRemovePost < BaseMutation
    # Note(AR): None of the fields are required, because this mutation can
    # either be called with `id` or with the pair `[collection_id, post_id]`
    #
    argument :id, ID, required: false
    argument_record :collection, Collection, required: false, authorize: :update
    argument_record :post, Post, required: false

    returns Graph::Types::CollectionPostType

    def perform(id: nil, collection: nil, post: nil)
      collection_post, error_values = find_collection_post(id, collection, post)
      return error(*error_values) if collection_post.blank?

      ApplicationPolicy.authorize!(current_user, :destroy, collection_post)
      Collections.remove(collection_post.collection, collection_post.post)

      collection_post
    end

    private

    def find_collection_post(id, collection, post)
      return [CollectionPostAssociation.find_by(id: id), %i(id blank)] if id
      return [nil, %i(collection_id blank)] if collection.nil?

      collection_post = collection.collection_post_associations.find_by(post: post)
      [collection_post, %i(post_id blank)]
    end
  end
end
