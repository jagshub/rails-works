# frozen_string_literal: true

module Mobile::Graph::Mutations
  class CollectionPostRemove < BaseMutation
    argument :id, ID, required: false
    argument_record :collection, Collection, required: false, authorize: :update
    argument_record :post, Post, required: false

    returns Mobile::Graph::Types::CollectionPostType

    def perform(id: nil, collection: nil, post: nil)
      return Collections.remove(collection, post)[:post_association] unless collection.nil? || post.nil?

      collection_post = find_collection_post(id, collection, post)
      return if collection_post.blank?

      ApplicationPolicy.authorize!(current_user, :destroy, collection_post)
      Collections.remove collection_post.collection, collection_post.post

      collection_post
    end

    private

    def find_collection_post(id, collection, post)
      return CollectionPostAssociation.find_by(id: id) if id.present?
      return if collection.nil?

      collection.collection_post_associations.find_by(post: post)
    end
  end
end
