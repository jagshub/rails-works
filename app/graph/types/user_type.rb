# frozen_string_literal: true

module Graph::Types
  class UserType < BaseObject
    implements Graph::Types::SeoInterfaceType
    implements Graph::Types::ShareableInterfaceType

    field :id, ID, null: false
    field :first_name, String, null: false
    field :header_uuid, String, null: true
    field :headline, String, null: true
    field :about, String, null: true
    field :avatar_url, String, null: true
    field :is_maker, resolver: Graph::Resolvers::Users::IsMaker
    field :is_ship_pro, Boolean, method: :ship_pro?, null: false
    field :is_trashed, Boolean, method: :trashed?, null: false
    field :name, String, null: false
    field :twitter_username, String, null: true
    field :username, String, null: false
    field :website_url, String, null: true
    field :links, [Graph::Types::UserLinkType], null: false
    field :created_at, Graph::Types::DateTimeType, resolver_method: :created_at, null: false, camelize: true
    field :email, String, null: true
    field :email_confirmed, Boolean, null: true, method: :email_confirmed?
    field :is_followed, resolver: Graph::Resolvers::Users::HasFollowed
    field :is_following_viewer, resolver: Graph::Resolvers::Users::IsFollowingViewerResolver
    field :is_viewer, Boolean, null: false, resolver_method: :viewer?
    field :role, String, null: false
    field :collections_count, Integer, null: false
    field :subscribed_collections_count, Integer, null: false
    field :followers_count, Integer, null: false
    field :followings_count, Integer, null: false
    field :products_count, Integer, null: false
    field :badges_count, Integer, null: false
    field :submitted_posts_count, Integer, null: false
    field :votes_count, Integer, null: false
    field :upcoming_pages_count, Integer, null: false
    field :subscribed_upcoming_pages_count, Integer, null: false
    field :collections, resolver: Graph::Resolvers::Collections::SearchResolver, null: false
    field :followed_topics, Graph::Types::TopicType.connection_type, max_page_size: 20, null: false, connection: true
    field :upcoming_pages, Graph::Types::UpcomingPageType.connection_type, max_page_size: 20, resolver: Graph::Resolvers::UpcomingPages::UserPagesResolver, null: false, connection: true
    field :subscribed_upcoming_pages, Graph::Types::UpcomingPageType.connection_type, max_page_size: 20, null: false, connection: true
    field :submitted_posts, Graph::Types::PostType.connection_type, max_page_size: 20, null: false, connection: true do
      argument :query, String, required: false
    end
    # TODO(DZ): Drop this
    field :subscribed_collections, Graph::Types::CollectionType.connection_type, max_page_size: 20, null: false, connection: true
    field :followers, Graph::Types::UserType.connection_type, max_page_size: 20, null: false, connection: true
    field :following, Graph::Types::UserType.connection_type, max_page_size: 20, null: false, connection: true
    field :comments, Graph::Types::CommentType.connection_type, max_page_size: 20, null: false, connection: true
    field :reviews, Graph::Types::ReviewType.connection_type, max_page_size: 20, null: false, connection: true
    field :karma_badge, Graph::Types::KarmaBadgeType, null: true
    field :post_cards, [Graph::Types::PostType], null: false, resolver: Graph::Resolvers::Posts::ProfileCardsResolver
    field :ambassador, Boolean, null: true
    field :crypto_wallet, String, null: true
    field :made_posts,
          Graph::Types::PostType.connection_type,
          resolver: Graph::Resolvers::Users::MadePostsSearchResolver,
          max_page_size: 20,
          null: false,
          connection: true
    field :all_posts, Graph::Types::PostType.connection_type, null: false, resolver: Graph::Resolvers::Users::AllPostsSearchResolver, max_page_size: 20, connection: true
    field :badges,
          Graph::Types::Badges::UserBadgeType.connection_type,
          resolver: Graph::Resolvers::Users::BadgesSearchResolver,
          max_page_size: 20,
          null: false,
          connection: true

    field :discussions, Graph::Types::Discussion::ThreadType.connection_type, max_page_size: 20, null: false, connection: true do
      argument :exclude_slug, String, required: false
    end

    field :recent_discussion, Graph::Types::Discussion::ThreadType, null: true do
      argument :maker_group_id, ID, required: false
    end

    field :voted_posts, Graph::Types::PostType.connection_type, max_page_size: 20, null: false, connection: true do
      argument :query, String, required: false
    end

    field :followed_products, Graph::Types::ProductType.connection_type, max_page_size: 20, null: false, connection: true
    field :followed_products_count, Integer, null: false

    field :badge_groups, resolver: Graph::Resolvers::Users::BadgeGroups
    field :badges_unique_count, Integer, null: false

    field :new_products, Graph::Types::ProductType.connection_type, null: false

    field :activity_events, Graph::Types::UserActivityEventType.connection_type, max_page_size: 20, resolver: Graph::Resolvers::Users::ActivityEvents, null: false

    def karma_badge
      Karma::Badge.for(object)
    end

    def recent_discussion(maker_group_id: nil)
      return object.recent_maker_discussion.where(subject_id: maker_group_id) if maker_group_id.present?

      object.recent_maker_discussion
    end

    def avatar_url
      Users::Avatar.cdn_url_for_user(object)
    end

    def viewer?
      object.id == context[:current_user]&.id
    end

    def admin?
      object.id == context[:current_user]&.id && object.admin?
    end

    def role
      context[:current_user] && context[:current_user].role == 'admin' ? object.role : 'user'
    end

    def followers_count
      object.follower_count
    end

    def followings_count
      object.friend_count
    end

    def products_count
      object.products.visible.count
    end

    def submitted_posts_count
      object.posts.visible.count
    end

    def followed_products
      object.followed_products.order('subscriptions.created_at DESC')
    end

    # Note(Raj): We should cache followed products count
    def followed_products_count
      object.followed_products.count
    end

    def voted_posts(query: '')
      scope = object.voted_posts.visible.by_featured_at

      return scope if query&.strip.blank?

      scope.where_like_slow(:name, query)
    end

    def submitted_posts(query: '')
      scope = if object == context[:current_user]
                object.posts.not_trashed.by_featured_at
              else
                object.posts.visible.by_featured_at
              end

      return scope if query&.strip.blank?

      scope.where_like_slow(:name, query)
    end

    def subscribed_collections
      Collection.joins(:subscriptions).where('collection_subscriptions.user_id' => object.id, 'collection_subscriptions.state' => CollectionSubscription.states['subscribed']).order(id: :desc)
    end

    def followers
      User.not_trashed.joins(:friends).where('user_friend_associations.following_user_id' => object.id)
    end

    def following
      User.not_trashed.joins(:followers).where('user_friend_associations.followed_by_user_id' => object.id)
    end

    def comments
      # Note (TC): We need to filter out comments for posts that the user has created
      # or is a listed maker on that have yet to launch.
      scope = object.comments.visible
                    .where(subject_type: ['Post', 'Discussion::Thread'])
                    .where.not(
                      subject_id: (object.posts.scheduled.ids + object.products.scheduled.ids),
                      subject_type: 'Post',
                    )
                    .by_date
      scope = scope.not_hidden if object != context[:current_user]
      scope
    end

    def reviews
      object.reviews.not_hidden.order(created_at: :desc)
    end

    def discussions(args = nil)
      return object.discussion_threads.where.not(slug: args[:exclude_slug]).visible unless args.nil?

      object.discussion_threads.visible
    end

    def email
      return unless context[:current_user]&.admin?

      object.email
    end

    def crypto_wallet
      object.crypto_wallet&.address
    end

    # NOTE(DZ): By chronological order of latest post
    def new_products
      object
        .new_products
        .select('DISTINCT(products.*), MAX(posts.scheduled_at)')
        .joins(:posts)
        .group('products.id')
        .where('posts.podcast': false)
        .where('products.posts_count > 0')
        .order('MAX(posts.scheduled_at) DESC')
    end
  end
end
