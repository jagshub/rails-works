# frozen_string_literal: true

module Graph::Types
  class CollectionType < BaseObject
    graphql_name 'Collection'

    implements Graph::Types::SeoInterfaceType
    implements Graph::Types::TopicableInterfaceType
    implements Graph::Types::FollowableInterfaceType
    implements Graph::Types::ShareableInterfaceType

    field :id, ID, null: false
    field :slug, String, null: false
    field :name, String, null: false
    field :description, String, null: true
    field :title, String, null: true
    field :user_id, ID, null: true
    field :image_uuid, String, null: true
    field :background_image_banner_url, String, null: true
    field :created_at, Graph::Types::DateTimeType, null: true
    field :updated_at, Graph::Types::DateTimeType, null: true
    field :followers_count,
          Int,
          null: false,
          method: :subscriber_count,
          deprecation_reason: 'Will be removed when product collection is released'
    field :posts_count,
          Int,
          null: false,
          deprecation_reason: 'Will be removed when product collection is released'
    field :is_followed,
          Boolean,
          null: false,
          resolver: Graph::Resolvers::Collections::HasFollowedResolver,
          deprecation_reason: 'Will be removed when product collection is released'
    field :followers,
          Graph::Types::UserType.connection_type,
          null: false,
          connection: true,
          deprecation_reason: 'Will be removed when product collection is released'
    field :is_featured, Boolean, null: false
    field :has_curator, Boolean, null: false
    # NOTE(rstankov): `collection_path/url` requires the collection curator
    field :path, String, null: false
    field :items,
          Graph::Types::CollectionPostType.connection_type,
          null: false, max_page_size: 50,
          connection: true,
          deprecation_reason: 'Will be removed when product collection is released'
    field :can_edit, Boolean, null: false, resolver: Graph::Resolvers::Can.build(:update)
    field :can_destroy, Boolean, null: false, resolver: Graph::Resolvers::Can.build(:destroy)
    field :personal, Boolean, null: false
    field :can_edit_curators,
          Boolean,
          null: false,
          resolver: Graph::Resolvers::Can.build(:edit_curators),
          deprecation_reason: 'Will be removed when product collection is released'

    field :products_count, Int, null: false

    field :has_collected_post,
          Boolean,
          null: false,
          deprecation_reason: 'Will be removed when product collection is released' do
      argument :id, ID, required: true
    end

    field :ad,
          Graph::Types::Ads::ChannelType,
          resolver: Graph::Resolvers::Ads::Channel

    field :products, Graph::Types::ProductType.connection_type, null: false do
      argument :live_first, Boolean, required: false, default_value: false
    end
    field :alternative_products, null: false, resolver: Graph::Resolvers::Collections::AlternativeProductsResolver
    field :has_product, Boolean, null: false, resolver: Graph::Resolvers::Collections::HasProduct

    # NOTE(DZ): Deprecated
    association :curators, [Graph::Types::UserType], null: false
    association :user, Graph::Types::UserType, null: false
    association :similar_collections, [Graph::Types::CollectionType], null: false

    def products(live_first:)
      live_first ? object.products.live_first : object.products
    end

    def posts_count
      object.posts.count
    end

    def followers
      context[:current_user] ? object.subscribers.order_by_friends(context[:current_user]) : object.subscribers
    end

    def is_featured
      object.featured?
    end

    def has_curator
      !object.without_curator?
    end

    def path
      Routes.collection_path(object)
    end

    def items
      object.collection_post_associations.order_by_credible_votes
    end

    def has_collected_post(id:)
      object.collection_post_associations.where(post_id: id).exists?
    end
  end
end
