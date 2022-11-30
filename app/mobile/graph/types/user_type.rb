# frozen_string_literal: true

module Mobile::Graph::Types
  class UserType < BaseNode
    field :about, String, null: true
    field :avatar_url, String, null: true
    field :badges_count, Integer, null: false
    field :badges, resolver: Mobile::Graph::Resolvers::Users::Badges
    field :badge_groups, resolver: Mobile::Graph::Resolvers::Users::BadgeGroups
    field :created_at, Mobile::Graph::Types::DateTimeType, null: false
    field :collections, resolver: Mobile::Graph::Resolvers::Collections::SearchResolver, max_page_size: 20, null: false
    field :collections_count, Integer, null: false
    field :default_collection, Mobile::Graph::Types::CollectionType, null: true
    field :followed_topics, Mobile::Graph::Types::TopicType.connection_type, max_page_size: 20, null: false, connection: true
    field :followed_products, Mobile::Graph::Types::ProductType.connection_type, max_page_size: 20, null: false, connection: true
    field :first_name, String, null: false
    field :followers, Mobile::Graph::Types::UserType.connection_type, max_page_size: 20, null: false, connection: true
    field :following, Mobile::Graph::Types::UserType.connection_type, max_page_size: 20, null: false, connection: true
    field :followers_count, Integer, null: false
    field :followings_count, Integer, null: false
    field :header_url, String, null: true do
      argument :width, Int, required: false
      argument :height, Int, required: false
    end
    field :headline, String, null: true
    field :is_following, resolver: Mobile::Graph::Resolvers::Users::IsFollowing
    field :is_following_viewer, resolver: Mobile::Graph::Resolvers::Users::IsFollowingViewer
    field :is_maker, Boolean, method: :maker?, null: false
    field :is_viewer, Boolean, resolver_method: :viewer?, null: false
    field :karma_badge, Mobile::Graph::Types::KarmaBadgeType, null: true
    field :made_posts_count, Integer, null: false
    field :made_posts, Mobile::Graph::Types::PostType.connection_type, max_page_size: 20, null: false, connection: true
    field :name, String, null: false
    field :submitted_posts, Mobile::Graph::Types::PostType.connection_type, max_page_size: 20, null: false, connection: true
    field :submitted_posts_count, Integer, null: false
    field :subscribed_collections, Mobile::Graph::Types::CollectionType.connection_type, max_page_size: 20, null: false, connection: true
    field :subscribed_collections_count, Integer, null: false
    field :twitter_username, String, null: true
    field :username, String, null: false
    field :voted_posts, Mobile::Graph::Types::PostType.connection_type, max_page_size: 20, null: false, connection: true
    field :voted_posts_count, Int, null: false
    field :website_url, String, null: true
    field :links, [Mobile::Graph::Types::UserLinkType], null: false
    field :badges_unique_count, Integer, null: false
    field :products, resolver: Mobile::Graph::Resolvers::Users::Products

    field :visit_streak_duration, Int, null: false

    def avatar_url
      Users::Avatar.cdn_url_for_user(object)
    end

    def followers
      User.not_trashed.joins(:friends).where('user_friend_associations.following_user_id' => object.id)
    end

    def following
      User.not_trashed.joins(:followers).where('user_friend_associations.followed_by_user_id' => object.id)
    end

    def followers_count
      object.follower_count
    end

    def followings_count
      object.friend_count
    end

    def header_url(width: nil, height: nil)
      Image.call(object.header_uuid, width: width, height: height)
    end

    def karma_badge
      Karma::Badge.for(object)
    end

    def made_posts_count
      object.products.visible.count
    end

    def made_posts
      object.products.visible.by_featured_at
    end

    def submitted_posts
      viewer? ? object.posts.not_trashed.by_featured_at : object.posts.visible.by_featured_at
    end

    def submitted_posts_count
      object.posts.visible.count
    end

    def subscribed_collections
      Collection.joins(:subscriptions).where(collection_subscriptions: { user_id: object.id, state: :subscribed }).order(id: :desc)
    end

    def viewer?
      object.id == current_user&.id
    end

    def visit_streak_duration
      ::UserVisitStreak.visit_streak_duration(object)
    end

    def voted_posts
      object.voted_posts.visible.by_featured_at
    end

    def voted_posts_count
      object.voted_posts.visible.count
    end
  end
end
