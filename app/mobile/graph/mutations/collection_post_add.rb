# frozen_string_literal: true

module Mobile::Graph::Mutations
  class CollectionPostAdd < BaseMutation
    argument_record :collection, Collection, required: false, authorize: :update
    argument_record :post, -> { Post.visible }

    require_current_user

    returns Mobile::Graph::Types::CollectionPostType

    def perform(collection: nil, post:)
      collection = default_collection if collection.blank?

      Collections.add(collection, post)[:post_association]
    end

    private

    def default_collection
      current_user.default_collection || create_default_collection
    end

    def create_default_collection
      Collection.transaction do
        collection = Collection.create!(user: current_user, name: "#{ current_user.friendly_name }'s Collection", personal: true)
        current_user.update!(default_collection_id: collection.id)
        collection
      end
    end
  end
end
