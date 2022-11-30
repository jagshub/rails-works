# frozen_string_literal: true

module API::V2Internal::Mutations
  class CollectionPostSaveForLater < BaseMutation
    argument :post_id, ID, required: true, camelize: false

    returns API::V2Internal::Types::CollectionPostType

    def perform
      return error :base, :access_denied if current_user.nil?

      collection = current_user.collections.saved_for_later || current_user.collections.create!(
        name: 'Save for Later',
        title: 'Saved products for later',
      )

      post = Post.find inputs[:post_id]

      Collections.add(collection, post)[:post_association]
    end
  end
end
