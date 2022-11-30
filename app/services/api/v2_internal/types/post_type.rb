# frozen_string_literal: true

module API::V2Internal::Types
  class PostType < BaseObject
    graphql_name 'Post'

    implements API::V2Internal::Types::VotableInterfaceType

    field :id, ID, null: false
    field :name, String, null: false
    field :slug, String, null: false
    field :tagline, String, null: false
    field :created_At, API::V2Internal::Types::DateTimeType, null: true, method: :scheduled_at
    field :featured_at, API::V2Internal::Types::DateTimeType, null: true
    field :reviews_count, Int, null: false
    field :votes_count, Int, null: false
    field :description, String, null: true, method: :description_text
    field :comments_count, Int, null: false
    field :feed_position, Int, null: false
    field :related_ad, resolver: API::V2Internal::Resolvers::Ads::ChannelResolver
    field :media, [API::V2Internal::Types::MediaType], null: false
    field :can_comment, resolver: ::Graph::Resolvers::Can.build(:new) { |obj| Comment.new(subject: obj) }
    field :is_collected, Boolean, null: false, resolver: API::V2Internal::Resolvers::IsPostCollectedResolver
    field :badges, API::V2Internal::Types::BadgeType.connection_type, null: false, connection: true
    field :comments, API::V2Internal::Types::CommentType.connection_type, max_page_size: 20, resolver: API::V2Internal::Resolvers::ThreadsResolver, null: false, connection: true
    field :topics, API::V2Internal::Types::TopicType.connection_type, max_page_size: 20, connection: true, null: false
    field :makers, [API::V2Internal::Types::UserType], null: true
    field :discussion_url, String, null: false
    field :is_launch_day, Boolean, null: false, resolver: API::V2Internal::Resolvers::Posts::IsLaunchDayResolver
    field :promo, API::V2Internal::Types::PostPromoType, null: true

    field :thumbnail,
          API::V2Internal::Types::MediaType,
          null: true,
          resolver: ::Posts::TemporaryMediaResolver,
          extras: [:graphql_name]

    association :user, API::V2Internal::Types::UserType, null: false

    field :product_links, [API::V2Internal::Types::ProductLinkType], null: false
    def product_links
      ::ProductLinksPresenter.decorate_links(post: object)
    end

    def makers
      object.makers.visible
    end

    def discussion_url
      ::Routes.post_url(object, ::Metrics.url_tracking_params(medium: :api, object: context[:current_application]))
    end

    def promo
      ::Posts::PromoCode.for_post(object)
    end

    ALLOWED_BADGES = ['Badges::TopPostBadge', 'Badges::GoldenKittyAwardBadge'].freeze

    def badges
      object.badges.where(type: ALLOWED_BADGES)
    end

    def feed_position
      object.daily_rank || 0
    end
  end
end
