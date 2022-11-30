# frozen_string_literal: true

module Mobile::Graph::Types
  class CollectionType < BaseNode
    graphql_name 'Collection'

    implements Mobile::Graph::Types::TopicableInterfaceType

    field :id, ID, null: false
    field :slug, String, null: false
    field :name, String, null: false
    field :description, String, null: true
    field :title, String, null: true
    field :image_uuid, String, null: true
    field :background_image_banner_url, String, null: true
    field :posts_count, Int, null: false
    field :created_at, Mobile::Graph::Types::DateTimeType, null: true
    field :updated_at, Mobile::Graph::Types::DateTimeType, null: true
    field :followers,
          Mobile::Graph::Types::UserType.connection_type,
          null: false,
          connection: true,
          deprecation_reason: 'Will be removed after moving to product-collection association'
    field :is_followed,
          resolver: Mobile::Graph::Resolvers::Collections::IsFollowed,
          deprecation_reason: 'Will be removed after moving to product-collection association'
    field :items, Mobile::Graph::Types::CollectionPostType.connection_type,
          null: false, max_page_size: 50, connection: true,
          deprecation_reason: 'Will be removed after moving to product-collection association'
    field :can_edit, resolver: Mobile::Graph::Utils::CanResolver.build(:update)
    field :can_destroy, resolver: Mobile::Graph::Utils::CanResolver.build(:destroy)
    field :can_edit_curators,
          resolver: Mobile::Graph::Utils::CanResolver.build(:edit_curators),
          deprecation_reason: 'Will be removed after moving to product-collection association'
    field :products_count, Int, null: false
    field :is_featured, Boolean, null: false
    field :has_default_curator, Boolean, null: false

    association :curators,
                [Mobile::Graph::Types::UserType],
                null: false,
                deprecation_reason: 'Will be removed after moving to product-collection association'
    association :user, Mobile::Graph::Types::UserType, null: false
    association :products, Mobile::Graph::Types::ProductType.connection_type, null: false

    def posts_count
      object.posts.count
    end

    def followers
      context[:current_user] ? object.subscribers.order_by_friends(context[:current_user]) : object.subscribers
    end

    # rubocop:disable Naming/PredicateName
    def is_featured
      object.featured?
    end

    def has_default_curator
      object.default_curator?
    end
    # rubocop:enable Naming/PredicateName

    def items
      object.collection_post_associations.order_by_credible_votes
    end
  end
end
