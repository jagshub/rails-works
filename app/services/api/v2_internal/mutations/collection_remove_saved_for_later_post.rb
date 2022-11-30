# frozen_string_literal: true

module API::V2Internal::Mutations
  class CollectionRemoveSavedForLaterPost < BaseMutation
    argument :post_id, ID, required: true, camelize: false

    returns API::V2Internal::Types::CollectionPostType

    def perform
      return error :base, :access_denied if current_user.nil?

      collection = current_user.collections.saved_for_later

      return error :base, :record_not_found if collection.nil?

      collection_post = collection.collection_post_associations.find_by post_id: inputs[:post_id]
      Collections.remove collection_post.collection, collection_post.post
      collection_post
    end
  end
end
