# frozen_string_literal: true

module API::V2::Types
  class UserType < BaseObject
    description 'A user.'

    field :id, ID, 'ID of the user.', null: false
    field :created_at, DateTimeType, 'Identifies the date and time when user was created.', null: false
    field :name, String, 'Name of the user.', null: false
    field :username, String, 'Username of the user.', null: false
    field :twitter_username, String, 'Twitter username of the user.', null: true
    field :headline, String, 'Headline text of the user.', null: true
    field :website_url, String, "URL for the user's website", null: true
    field :url, String, "Public URL of the user's profile", null: false

    field :cover_image, String, 'Cover image of the user.', resolver: API::V2::Resolvers::ImageResolver.generate(null: true, &:header_uuid)
    field :profile_image, String, 'Profile image of the user.', null: true do
      argument :size, Int, required: false
    end

    field :is_maker, Boolean, 'Whether the user is an accepted maker or not.', null: false, method: :maker?
    field :is_viewer, Boolean, 'Whether the user is same as the viewer of the API.', null: false, resolver_method: :viewer?
    field :is_following, Boolean, 'Whether the viewer is following the user or not.', resolver: API::V2::Resolvers::Users::IsFollowingResolver, complexity: 2

    field :voted_posts, PostType.connection_type, 'Look up posts that the user has voted for.', null: false
    field :submitted_posts, PostType.connection_type, 'Look up posts that the user has submitted.', null: false
    field :made_posts, PostType.connection_type, 'Look up posts that the user has made.', null: false

    field :followed_collections, CollectionType.connection_type, 'Look up collections that the user is following.', null: false

    field :followers, UserType.connection_type, 'Look up other users who are following the user.', null: false
    field :following, UserType.connection_type, 'Look up other users who are being followed by the user.', null: false

    def url
      Routes.profile_url(object, url_tracking_params)
    end

    def profile_image(size: nil)
      Users::Avatar.url_for_user(object, size: size || 'original')
    end

    def viewer?
      object.id == current_user&.id
    end

    def voted_posts
      object.voted_posts.visible.by_featured_at
    end

    def submitted_posts
      object.posts.visible.by_featured_at
    end

    def made_posts
      object.products.visible.by_featured_at
    end

    def followers
      User.not_trashed.joins(:friends).where('user_friend_associations.following_user_id' => object.id)
    end

    def following
      User.not_trashed.joins(:followers).where('user_friend_associations.followed_by_user_id' => object.id)
    end

    def followed_collections
      Collection.joins(:subscriptions).where('collection_subscriptions.user_id' => object.id, 'collection_subscriptions.state' => CollectionSubscription.states['subscribed']).order(id: :desc)
    end
  end
end
