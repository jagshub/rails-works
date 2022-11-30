# frozen_string_literal: true

module Mobile::Graph::Types
  class ProductType < BaseObject
    implements SubscribableInterfaceType

    graphql_name 'Product'

    field :id, ID, null: false
    field :slug, String, null: false
    field :name, String, null: false
    field :logo_uuid, String, null: true, method: :logo_uuid_with_fallback
    field :tagline, String, null: false

    field :formatted_description, FormattedTextType, null: true, method: :description

    field :created_at, DateTimeType, null: false
    field :updated_at, DateTimeType, null: false

    field :is_maker, Boolean, null: false, resolver_method: :maker?

    field :posts_count, Integer, null: false
    field :topics_count, Integer, null: false
    field :followers_count, Integer, null: false, deprecation_reason: 'Renamed, use subscribers_count instead'
    field :subscribers_count, Integer, null: false, method: :followers_count
    field :total_votes_count, Integer, null: false

    field :can_review, resolver: Graph::Resolvers::Can.build(:create) { |obj| Review.new(product: obj) }

    field :review_tags, [ReviewTagType], null: false
    field :reviewers, UserType.connection_type, max_page_size: 20, connection: true, null: false
    field :reviews, ReviewType.connection_type, max_page_size: 20, resolver: Mobile::Graph::Resolvers::Products::Reviews, null: false, connection: true
    field :reviews_count, Int, null: false
    field :reviews_rating, Float, null: true
    field :reviews_with_body_count, Int, null: false
    field :reviews_with_rating_count, Int, null: false

    field :viewer_review, ReviewType, null: true

    field :topics, TopicType.connection_type

    field :media, [MediaType], null: false
    field :makers, [UserType], null: false

    field :platforms, [String], null: false

    field :ios_url, String, null: true
    field :android_url, String, null: true
    field :website_url, String, null: false

    field :posts, Mobile::Graph::Types::PostType.connection_type, resolver: Mobile::Graph::Resolvers::Products::Posts, null: false, connection: true

    field :maker_posts,
          resolver: Mobile::Graph::Resolvers::Products::PostsByUsernameResolver,
          null: false

    association :followers, UserType.connection_type, null: false, deprecation_reason: 'Renamed, use subscribers instead'
    association :subscribers, UserType.connection_type, null: false, preload: :followers

    field :related_products, ProductType.connection_type, null: false, connection: true

    def related_products
      object.associated_products
    end

    field :badges, Mobile::Graph::Types::BadgeType.connection_type, null: false, max_page_size: 200, connection: true

    field :badges_count, Int, null: false

    ALLOWED_BADGES = %w(Badges::TopPostBadge Badges::GoldenKittyAwardBadge).freeze

    def badges_count
      object.badges.where(type: ALLOWED_BADGES).count
    end

    def badges
      object.badges.where(type: ALLOWED_BADGES)
    end

    def review_tags
      ReviewTag.all
    end

    def viewer_review
      return if context[:current_user].blank?

      object.reviews.where(user: context[:current_user]).first
    end

    def maker?
      current_user = context[:current_user]
      return false if current_user.blank?

      object.makers.pluck(:id).include?(current_user&.id)
    end

    def reviews_rating_specific_count
      Posts::ReviewRating.rating_specific_count(object)
    end

    def topics
      object.featured_topics.presence || object.topics
    end

    def media
      if object.media_count.zero?
        object.latest_post&.media || []
      else
        object.media.by_priority
      end
    end

    def ios_url
      ::Products.ios_url(object)
    end

    def android_url
      ::Products.android_url(object)
    end
  end
end
