# frozen_string_literal: true

module Graph::Types
  class PostType < BaseObject
    implements Graph::Types::CommentableInterfaceType
    implements Graph::Types::TopicableInterfaceType
    implements Graph::Types::ShareableInterfaceType
    implements Graph::Types::VotableInterfaceType
    implements Graph::Types::SeoInterfaceType
    implements Graph::Types::SubscribableInterfaceType
    implements Graph::Types::BadgeableInterfaceType

    field :id, ID, null: false
    field :comments_count, Integer, null: false
    field :alternatives_count, Integer, null: false
    field :name, String, null: false
    field :slug, String, null: false
    field :tagline, String, null: false
    field :thumbnail_image_uuid, String, null: true
    field :social_media_image_uuid, String, null: true
    field :created_at, Graph::Types::DateTimeType, method: :date, null: false
    field :updated_at, Graph::Types::DateTimeType, null: false
    field :featured_at, Graph::Types::DateTimeType, null: true
    field :trashed_at, Graph::Types::DateTimeType, null: true
    field :description, Graph::Types::HTMLType, null: true
    field :votes_count, resolver: Graph::Resolvers::Posts::VotesCountResolver
    field :user_id, ID, null: false
    field :disabled_when_scheduled, Boolean, null: false
    field :product_id, Integer, null: false
    field :daily_rank, Integer, null: true
    field :weekly_rank, Integer, null: true
    field :locked, Boolean, null: true
    field :featured_comment, resolver: Graph::Resolvers::Posts::FeaturedComment
    field :maker_comment, Graph::Types::CommentType, null: true
    field :pricing_type, Graph::Types::PostPricingTypeEnum, null: true
    field :upvote_demographics, resolver: Graph::Resolvers::Posts::UpvoteDemographicsResolver
    field :upvote_time_series, resolver: Graph::Resolvers::Posts::UpvoteTimeSeriesResolver
    field :contributors, [Graph::Types::PostContributorType], resolver: Graph::Resolvers::Posts::ContributorsResolver, null: false
    field :show_daily_rank, Boolean, method: :show_daily_rank?, null: false
    field :show_weekly_rank, Boolean, method: :show_weekly_rank?, null: false
    field :comment_prompts, [Graph::Types::CommentPromptType], null: false
    field :makers_count, Integer, null: false

    association :positive_review_tags, [Graph::Types::Reviews::TagType], null: false
    association :negative_review_tags, [Graph::Types::Reviews::TagType], null: false

    field :is_hunter, Boolean, null: false

    field :is_archived, Boolean, null: false, method: :archived?

    field :redirect_to_product, resolver: Graph::Resolvers::Posts::RedirectToProductResolver

    def is_hunter
      object.user_id == context[:current_user]&.id
    end

    field :promo, Graph::Types::PostPromoType, null: true do
      argument :show, Boolean, required: false, default_value: false
    end

    def promo(show:)
      Posts::PromoCode.for_post(object, ignore_expiration: show)
    end

    field :url, String, null: false

    def url
      Routes.post_url(object)
    end

    field :path, String, null: false

    def path
      Routes.post_path(object)
    end

    field :shortened_url, String, null: false

    def shortened_url
      Routes.short_link_to_post_path(object.id)
    end

    association :user, Graph::Types::UserType, null: false
    association :product, Graph::Types::ProductType, null: true, preload: :new_product
    field :product_state, String, null: false

    # Note(AR): This is *only* used in the browser extension
    field :share_image_uuid,
          String,
          resolver: Graph::Resolvers::Posts::ShareImageUuidResolver,
          null: false

    field :primary_link, Graph::Types::ProductLinkType, null: false
    association :links,
                [Graph::Types::ProductLinkType],
                method: lambda { |_links, obj|
                  ProductLinksPresenter.decorate_links(post: obj)
                },
                null: false
    # Note(AR): Duplicated for compatibility reasons
    field :product_links, [Graph::Types::ProductLinkType], null: false
    def product_links
      ProductLinksPresenter.decorate_links(post: object)
    end

    Product::SOCIAL_LINKS.each do |link_attr|
      association link_attr,
                  String,
                  preload: :new_product,
                  method: ->(_assoc, object) { object&.new_product&.public_send(link_attr) },
                  null: true
    end

    association :media, [Graph::Types::MediaType], preload: :media, null: false

    field :makers, [Graph::Types::UserType], null: false

    def makers
      object.visible_makers
    end

    field :moderation_reason, Graph::Types::ModerationReasonType, null: true

    def moderation_reason
      ::Moderation.public_reason(post: object)
    end

    field :vote_chaining_posts, [Graph::Types::PostType], null: false

    def vote_chaining_posts
      VoteChaining.posts(post: object, current_user: context[:current_user])
    end

    field :vote_chaining_posts_count, Integer, null: false

    def vote_chaining_posts_count
      VoteChaining.count(post: object, current_user: context[:current_user])
    end

    field :can_manage, resolver: Graph::Resolvers::Can.build(:edit)

    field :seo_queries,
          [Graph::Types::Seo::QueryType],
          camelize: true,
          null: false

    def seo_queries
      return [] unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MODERATE, object)

      object.seo_queries
    end

    field :is_collected,
          camelize: true,
          resolver: Graph::Resolvers::Posts::IsCollected

    field :embed_badge_message,
          Graph::Types::EmbedPostBadgeMessageType, null: true

    def embed_badge_message
      Posts::EmbedBadgeMessage.call(object, context)
    end

    field :related_posts_count, Integer, null: false, camelize: true

    field :connected_posts,
          Graph::Types::PostType.connection_type,
          null: true,
          connection: true

    field :maker_invite_url, String, null: true

    def maker_invite_url
      return unless ApplicationPolicy.can?(context[:current_user], :edit, object)

      Posts::MakerInviteCode.url(object)
    end

    field :is_maker_invite_code_valid, Boolean, null: false do
      argument :code, String, required: false
    end

    field :is_maker, resolver: Graph::Resolvers::IsMakerResolver

    def is_maker_invite_code_valid(**args)
      Posts::MakerInviteCode.valid?(object, args[:code])
    end

    field :submission,
          Graph::Types::PostSubmissionType,
          null: true

    def submission
      return unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object
    end

    field :primary_ad, Graph::Types::Ads::ChannelType,
          camelize: true,
          resolver: Graph::Resolvers::Ads::Channel

    field :second_ad, Graph::Types::Ads::ChannelType,
          camelize: true,
          resolver: Graph::Resolvers::Ads::Channel

    field :third_ad, Graph::Types::Ads::ChannelType,
          camelize: true,
          resolver: Graph::Resolvers::Ads::Channel

    field :possible_duplicate_posts,
          camelize: true,
          resolver: Graph::Resolvers::Moderation::PossibleDuplicatePosts

    field :is_available, Boolean, null: false, resolver_method: :available?

    def available?
      object.product_state != 'no_longer_online'
    end

    field :recommendations, Graph::Types::RecommendationType.connection_type, null: true, connection: true
    field :product_requests, Graph::Types::ProductRequestType.connection_type, null: true, connection: true
    field :questions, Graph::Types::QuestionType.connection_type, null: true, connection: true
    field :launch_state, String, null: false

    def launch_state
      object.state
    end

    def maker_comment
      object
        .comments
        .visible
        .top_level
        .order('created_at ASC')
        .find_by(user_id: object.maker_ids)
    end

    association :twitter_follower_count,
                Integer,
                null: true,
                preload: { new_product: :twitter_follower_count },
                method: ->(_assoc, object) { object.new_product&.twitter_follower_count&.follower_count }

    field :web3_chain, resolver: Graph::Resolvers::Web3::ChainResolver, null: true

    association :upcoming_event, Graph::Types::Upcoming::EventType, null: true

    field :can_create_upcoming_event,
          Boolean,
          null: false,
          resolver: Graph::Resolvers::Can.build(:create_upcoming_event)

    field :can_view_upcoming_event_create_btn,
          Boolean,
          null: false,
          resolver: Graph::Resolvers::Can.build(:view_upcoming_event_create_btn)
  end
end
