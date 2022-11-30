# frozen_string_literal: true

module Graph::Types
  class ProductType < BaseObject
    implements SeoInterfaceType
    implements SubscribableInterfaceType
    implements Graph::Types::TopicableInterfaceType
    implements Graph::Types::ReviewableInterfaceType
    implements Graph::Types::BadgeableInterfaceType
    implements Graph::Types::ShareableInterfaceType

    graphql_name 'Product'

    field :id, ID, null: false
    field :slug, String, null: false
    field :name, String, null: false
    field :logo_uuid, String, null: true
    field :tagline, String, null: false
    field :description, String, null: true
    field :website_url, String, null: false
    field :website_domain, String, null: false
    field :clean_url, String, null: false
    field :created_at, Graph::Types::DateTimeType, null: false
    field :reviewed, Boolean, null: false
    field :visible, Boolean, null: false
    field :posts_count, Integer, null: false
    field :topics_count, Integer, null: false
    field :followers_count, Integer, null: false
    field :jobs_count, Integer, null: false
    field :makers, [UserType], null: false
    field :media, [MediaType], null: false
    field :media_images, [MediaType], null: false
    field :platforms, [String], null: false
    field :ios_url, String, null: true
    field :android_url, String, null: true
    field :source, String, null: false
    field :is_trashed, Boolean, null: false, method: :trashed?
    field :is_live, Boolean, null: false, method: :live?
    field :is_no_longer_online, Boolean, null: false, method: :no_longer_online?
    association :jobs, [JobType], null: false
    association :positive_review_tags, [Graph::Types::Reviews::TagType], null: false
    association :negative_review_tags, [Graph::Types::Reviews::TagType], null: false
    field :reviewers_count, Integer, null: false
    field :url, String, null: false
    field :primary_ad,
          Graph::Types::Ads::ChannelType,
          resolver: Graph::Resolvers::Ads::Channel

    field :recommended_products,
          [Graph::Types::ProductType],
          resolver: Graph::Resolvers::Products::RecommendedProducts,
          null: false

    field :followers, Graph::Types::UserType.connection_type, resolver: Graph::Resolvers::Products::FollowersResolver, null: false
    field :is_maker, Boolean, null: false

    def is_maker
      object.makers.include?(context[:current_user])
    end

    field :can_maintain, type: Boolean, null: false
    def can_maintain
      ApplicationPolicy.can?(context[:current_user], :maintain, object)
    end

    field :can_edit, type: Boolean, null: false
    def can_edit
      ApplicationPolicy.can?(context[:current_user], :edit, object)
    end

    # TODO(Vlado): Counter cache
    field :team_members_count, Integer, null: false
    def team_members_count
      object.team_members.count
    end

    field :team_members, [Graph::Types::Team::MemberType],
          resolver: Graph::Resolvers::Team::MembersResolver, null: false

    field :team_requests, [Graph::Types::Team::RequestType], null: false
    def team_requests
      return [] unless can_edit

      object.team_requests.pending
    end

    field :team_invites, [Graph::Types::Team::InviteType], null: false
    def team_invites
      return [] unless can_edit

      object.team_invites.pending
    end

    field :is_claimed, Boolean, null: false
    def is_claimed
      object.team_members.owner.exists?
    end

    field :viewer_pending_team_request, Graph::Types::Team::RequestType, null: true
    def viewer_pending_team_request
      return unless context[:current_user]

      object.team_requests.pending.find_by(user: context[:current_user])
    end

    field :is_viewer_team_member, Boolean, null: true
    def is_viewer_team_member
      return unless context[:current_user]

      object.team_members.exists?(user: context[:current_user])
    end

    field :posts,
          Graph::Types::PostType.connection_type,
          resolver: Graph::Resolvers::Products::PostsResolver, null: false,
          connection: true

    # Note(AR): No pagination, we want to be able to load all of the posts in
    # the moderation form so we can submit all the post ids.
    field :moderation_posts, [Graph::Types::PostType], null: false

    field :maker_posts,
          resolver: Graph::Resolvers::Products::PostsByUsernameResolver,
          null: false

    def moderation_posts
      return [] unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MODERATE, object)

      object.posts.visible.by_created_at
    end

    field :latest_post, Graph::Types::PostType, null: true

    field :screenshots,
          Graph::Types::Products::ScreenshotType.connection_type,
          null: false,
          connection: true

    field :questions, Graph::Types::QuestionType.connection_type, null: false

    def questions
      object.questions.order('created_at DESC')
    end

    def topics
      object.featured_topics.presence || object.topics
    end

    field :activity_events,
          Graph::Types::Products::ActivityEventType.connection_type,
          max_page_size: 20,
          resolver: Graph::Resolvers::Products::ActivityEvents, null: false,
          connection: true

    field :stories, [Graph::Types::Anthologies::StoryType], null: false do
      argument :first, Integer, required: true
    end

    field :alternative_associations,
          Graph::Types::ProductAssociationType.connection_type,
          resolver: Graph::Resolvers::Products::AlternativeAssociationsSearchResolver,
          null: false,
          connection: true

    field :alternatives_image, String, null: false

    def alternatives_image
      External::Url2pngApi.share_url(::Products::Alternatives.new(object))
    end

    field :alternatives_count, Integer, null: false

    field :addons,
          Graph::Types::ProductType.connection_type,
          resolver: Graph::Resolvers::Products::AddonsResolver,
          null: false,
          connection: true

    field :addons_count, Integer, null: false
    field :related_products_count, Integer, null: false
    field :associated_products_count, Integer, null: false

    field :facebook_url, String, null: true
    field :instagram_url, String, null: true
    field :twitter_url, String, null: true
    field :twitter_username, String, null: true

    def twitter_username
      NormalizeTwitter.username(object.twitter_url)
    end

    field :total_votes_count, Integer, null: false
    field :promo, Graph::Types::PostPromoType, null: true

    def promo
      Posts::PromoCode.for_post(object.latest_post, ignore_expiration: false)
    end

    field :first_post, Graph::Types::PostType, null: true
    field :active_upcoming_event, Upcoming::EventType, null: true
    field :current_upcoming_events, [Upcoming::EventType], null: false

    def logo_uuid
      object.logo_uuid_with_fallback
    end

    def media_images
      images = media

      if images.empty?
        images
      else
        images.image.limit(3)
      end
    end

    def media
      if object.media_count.zero?
        object.latest_post&.media || []
      else
        object.media.by_priority
      end
    end

    def topics(first:)
      object.topics.order('followers_count DESC').limit(first)
    end

    def ios_url
      ::Products.ios_url(object)
    end

    def android_url
      ::Products.android_url(object)
    end

    def url
      Routes.product_url(object)
    end

    def stories(first:)
      ::Anthologies::Story
        .joins(:post_mentions)
        .where(posts: { id: object.post_ids })
        .by_published_at
        .limit(first)
    end

    def reviewers
      object.reviewers_for_feed(current_user: context[:current_user])
    end

    def positive_review_tags
      object.positive_review_tags_for_feed
    end

    def reviewers_count
      object.reviewers.distinct.count
    end

    field :stacks_count, Integer, null: false
    field :is_stacked, resolver: Graph::Resolvers::Products::IsStackedResolver
  end
end
