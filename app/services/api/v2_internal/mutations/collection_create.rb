# frozen_string_literal: true

module API::V2Internal::Mutations
  class CollectionCreate < BaseMutation
    argument :name, String, camelize: false, required: true
    argument :post_id, ID, camelize: false, required: true

    returns API::V2Internal::Types::CollectionType

    def perform
      post_id = inputs[:post_id]

      return error :post_id, :blank if post_id.blank?
      return error :base, :access_denied if current_user.nil?

      collection = HandleRaceCondition.call { current_user.collections.create(name: inputs[:name]&.strip) }

      return errors_from_record collection if collection.errors.any?

      collection_post = Collections.add(collection, Post.find(post_id))[:post_association]

      if collection_post.errors.empty?
        success collection
      else
        errors_from_record collection_post
      end
    end
  end
end
