# frozen_string_literal: true

module API::V2Internal::Types
  class CollectionType < BaseObject
    graphql_name 'Collection'

    field :id, ID, null: false
    field :name, String, null: false
    field :tagline, String, null: true, method: :title
    field :posts_count, Int, null: true, method: :posts_count
    field :background_image_banner_url, String, null: true, camelize: false
    field :created_at, API::V2Internal::Types::DateTimeType, null: false, method: :created_at
    field :updated_at, API::V2Internal::Types::DateTimeType, null: false, method: :updated_at
    field :can_destroy, resolver: ::Graph::Resolvers::Can.build(:destroy)
    field :items, API::V2Internal::Types::CollectionPostType.connection_type, max_page_size: 50, connection: true, null: false

    field :has_collected_post, Boolean, null: true do
      argument :id, ID, required: false
    end

    def has_collected_post(id:) # rubocop:disable Naming/PredicateName
      object.collection_post_associations.where(post_id: id).exists?
    end

    def items
      object.collection_post_associations.joins(:post).order('votes_count DESC')
    end
  end
end
