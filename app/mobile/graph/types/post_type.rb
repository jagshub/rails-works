# frozen_string_literal: true

module Mobile::Graph::Types
  class PostType < BaseNode
    implements Mobile::Graph::Types::CommentableInterfaceType
    implements Mobile::Graph::Types::VotableInterfaceType

    field :collections, Mobile::Graph::Types::CollectionType.connection_type, null: false
    field :comments_count, Integer, null: false
    field :created_at, Mobile::Graph::Types::DateTimeType, method: :date, null: false
    field :description, Mobile::Graph::Types::HTMLType, null: true, deprecation_reason: 'Use formattedDescription'
    field :description_md, String, null: true, deprecation_reason: 'Use formattedDescription'
    field :formatted_description, FormattedTextType, null: true, method: :description
    field :featured_at, Mobile::Graph::Types::DateTimeType, null: true
    field :is_collected, resolver: Mobile::Graph::Resolvers::Posts::IsCollected
    field :name, String, null: false
    field :slug, String, null: false
    field :tagline, String, null: false
    field :thumbnail_image_uuid, String, null: true
    field :trashed_at, Mobile::Graph::Types::DateTimeType, null: true
    field :updated_at, Mobile::Graph::Types::DateTimeType, null: false
    field :pricing_type, Mobile::Graph::Types::PostPricingTypeEnum, null: true
    field :is_archived, Boolean, null: false, method: :archived?
    field :daily_rank, Integer, null: true
    field :show_daily_rank, Boolean, method: :show_daily_rank?, null: false

    field :topics, [Mobile::Graph::Types::TopicType], null: false, deprecation_reason: 'Use topics_list'
    field :topics_list, TopicType.connection_type, method: :topics

    field :badges, Mobile::Graph::Types::BadgeType.connection_type, null: false, connection: true

    ALLOWED_BADGES = %w(Badges::TopPostBadge Badges::GoldenKittyAwardBadge).freeze

    def badges
      object.badges.where(type: ALLOWED_BADGES)
    end

    association :media, [Mobile::Graph::Types::MediaType], preload: :media, null: false
    association :user, Mobile::Graph::Types::UserType, null: false
    association :product, Mobile::Graph::Types::ProductType, null: true, preload: :new_product

    def collections
      object.collections.visible(current_user).for_curator(user: current_user)
    end

    def description_md
      return if object.description.blank?

      ::ReverseMarkdown.convert object.description
    end

    field :related_posts_count, Integer, null: false
    field :makers, [Mobile::Graph::Types::UserType], null: false

    def makers
      object.visible_makers
    end

    association :links,
                [Mobile::Graph::Types::ProductLinkType],
                method: lambda { |_links, obj|
                  ProductLinksPresenter.decorate_links(post: obj)
                },
                null: false

    field :related_posts, [Mobile::Graph::Types::PostType], null: false, resolver: Mobile::Graph::Resolvers::Posts::RelatedPosts do
      argument :limit, Integer, required: false
    end
  end
end
