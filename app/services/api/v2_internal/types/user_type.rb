# frozen_string_literal: true

module API::V2Internal::Types
  class UserType < BaseObject
    graphql_name 'User'

    field :id, ID, null: false
    field :name, String, null: false
    field :first_name, String, null: false
    field :username, String, null: false
    field :twitter_username, String, null: true
    field :headline, String, null: true
    field :is_maker, Boolean, method: :maker?, null: false
    field :website_url, String, null: true
    field :created_at, API::V2Internal::Types::DateTimeType, null: false
    field :followers_count, Int, null: false, method: :follower_count
    field :friends_count, Int, null: false, method: :friend_count

    field :header_url, String, null: true do
      argument :width, Int, required: false
      argument :height, Int, required: false
    end

    def header_url(width:, height:)
      Image.call(object.header_uuid, width: width, height: height)
    end

    field :avatar_url, String, null: true

    def avatar_url
      Users::Avatar.cdn_url_for_user(object)
    end

    field :is_viewer, Boolean, null: false

    def is_viewer # rubocop:disable Naming/PredicateName
      object.id == context[:current_user]&.id
    end

    field :is_following, Boolean, null: false, resolver: API::V2Internal::Resolvers::IsFollowingResolver

    field :voted_posts_count, Int, null: false

    def voted_posts_count
      object.voted_posts.visible.count
    end

    field :submitted_posts_count, Int, null: false

    def submitted_posts_count
      object.posts.visible.count
    end

    field :made_posts_count, Int, null: false

    def made_posts_count
      object.products.visible.count
    end

    field :collections_count, Int, null: false

    def collections_count
      Collection.for_curator(user: object).count
    end

    field :karma_badge, API::V2Internal::Types::KarmaBadgeType, null: true

    def karma_badge
      Karma::Badge.for(object)
    end

    field :voted_posts, API::V2Internal::Types::PostType.connection_type, max_page_size: 30, null: false, connection: true

    def voted_posts
      object.voted_posts.visible.by_featured_at
    end

    field :submitted_posts, API::V2Internal::Types::PostType.connection_type, max_page_size: 30, null: false, connection: true

    def submitted_posts
      object.posts.visible.by_featured_at
    end

    field :made_posts, API::V2Internal::Types::PostType.connection_type, max_page_size: 30, null: false, connection: true

    def made_posts
      object.products.visible.by_featured_at
    end

    field :followers, API::V2Internal::Types::UserType.connection_type, max_page_size: 20, null: false, connection: true

    def followers
      User.not_trashed.joins(:friends).where('user_friend_associations.following_user_id' => object.id)
    end

    field :following, API::V2Internal::Types::UserType.connection_type, max_page_size: 20, null: false, connection: true

    def following
      User.not_trashed.joins(:followers).where('user_friend_associations.followed_by_user_id' => object.id)
    end
  end
end
