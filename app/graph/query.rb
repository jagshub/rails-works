# frozen_string_literal: true

class Graph::Query < Graph::Types::BaseObject
  graphql_name 'Query'

  field :post, resolver: Graph::Resolvers::SlugOrId.build(Post)
  field :posts_top, resolver: Graph::Resolvers::Posts::TopPostsResolver

  field :product, resolver: Graph::Resolvers::SlugOrId.build(Product)
  field :products, Graph::Types::Products::ConnectionType, max_page_size: 20, resolver: Graph::Resolvers::Products::SearchResolver, null: false, connection: true

  field :product_by_url, resolver: Graph::Resolvers::Products::FindByUrlResolver
  field :products_for_post_name, resolver: Graph::Resolvers::Products::FindByPostNameResolver
  field :top_products, resolver: Graph::Resolvers::Products::TopProductsResolver

  field :topic, resolver: Graph::Resolvers::SlugOrId.build(Topic)

  field :collection, resolver: Graph::Resolvers::Collections::Collection

  field :user, Graph::Types::UserType, null: true do
    argument :username, String, required: true
    argument :include_all, Boolean, required: false
  end

  def user(username:, include_all: false)
    if include_all
      User.find_by(username: username.downcase)
    else
      User.find_by(username: username.downcase, trashed_at: nil)
    end
  end

  field :upcoming_pages, Graph::Types::UpcomingPageType.connection_type, max_page_size: 20, resolver: Graph::Resolvers::UpcomingPages::SearchResolver, null: false, connection: true

  field :upcoming_pages_card, resolver: Graph::Resolvers::UpcomingPages::Card

  field :upcoming_events, resolver: Graph::Resolvers::Upcoming::EventsResolver

  field :ship_public_stats, resolver: Graph::Resolvers::Ships::PublicStats

  field :ship_account, resolver: Graph::Resolvers::Ships::Accounts::ById

  field :ship_contact, resolver: Graph::Resolvers::Ships::Contacts::ById

  field :ship_instant_access_page, resolver: Graph::Resolvers::SlugOrId.build(ShipInstantAccessPage.not_trashed, Graph::Types::ShipInstantAccessPageType)

  field :upcoming_page, resolver: Graph::Resolvers::SlugOrId.build(UpcomingPage.not_trashed, Graph::Types::UpcomingPageType)

  field :upcoming_page_message, resolver: Graph::Resolvers::UpcomingPages::Message

  field :upcoming_page_subscriber, resolver: Graph::Resolvers::UpcomingPages::Subscriber

  field :upcoming_page_survey, resolver: Graph::Resolvers::UpcomingPages::Surveys::ById

  field :checkout_page, resolver: Graph::Resolvers::SlugOrId.build(CheckoutPage.not_trashed, Graph::Types::CheckoutPageType)

  field :familiar_users, resolver: Graph::Resolvers::Users::FamiliarUsers

  field :suggested_users, resolver: Graph::Resolvers::Users::SuggestedUsers

  field :question, resolver: Graph::Resolvers::Question

  field :questions, resolver: Graph::Resolvers::Questions

  field :comment, Graph::Types::CommentType, null: true do
    argument :id, ID, required: true
  end

  def comment(id:)
    Comment.find_by id: id
  end

  field :ship_lead, Graph::Types::ShipLeadType, null: true

  def ship_lead
    Ships::Leads.from_context(context)
  end

  field :viewer, Graph::Types::ViewerType, null: false

  def viewer
    :viewer
  end

  field :newsletter, resolver: Graph::Resolvers::Newsletter

  field :dismissed, resolver: Graph::Resolvers::Dismissed

  field :maker_main_group, Graph::Types::MakerGroupType, null: false do
    argument :beta, String, required: false
  end

  def maker_main_group(beta: nil)
    MakerGroups.find_group(beta, context[:current_user])
  end

  field :users, Graph::Types::UserType.connection_type, max_page_size: 100, resolver: Graph::Resolvers::Users::SearchResolver, null: false, connection: true
  field :posts, Graph::Types::PostType.connection_type, max_page_size: 20, resolver: Graph::Resolvers::Posts::PostsResolver, null: false, connection: true

  field :random_post, resolver: Graph::Resolvers::Posts::RandomPost

  field :topics, Graph::Types::TopicType.connection_type, max_page_size: 1000, resolver: Graph::Resolvers::Topics::TopicsResolver, null: false, connection: true
  field :collections, resolver: Graph::Resolvers::Collections::SearchResolver, null: false
  field :newsletters, Graph::Types::NewsletterType.connection_type, max_page_size: 20, resolver: Graph::Resolvers::Newsletters, null: false, connection: true
  field :jobs, Graph::Types::JobType.connection_type, max_page_size: 20, resolver: Graph::Resolvers::Jobs::SearchResolver, null: false, connection: true

  field :job_board, Graph::Types::JobBoardType, null: false, resolver: Graph::Resolvers::Jobs::SearchResolver

  field :shoutout, resolver: Graph::Resolvers::Shoutouts::FindResolver, null: true
  field :shoutouts, Graph::Types::ShoutoutType.connection_type, max_page_size: 20, resolver: Graph::Resolvers::Shoutouts::SearchResolver, null: false, connection: true

  field :jobs_discount_page, Graph::Types::JobsDiscountPageType, null: true do
    argument :slug, String, required: false
  end

  def jobs_discount_page(slug:)
    Jobs::DiscountPage.find_by slug: slug
  end

  field :story, resolver: Graph::Resolvers::SlugOrId.build(Anthologies::Story)

  field :stories, Graph::Types::Anthologies::StoryType.connection_type, max_page_size: 20, resolver: Graph::Resolvers::Anthologies::StoriesResolver, null: false, connection: true
  field :story_category, resolver: Graph::Resolvers::Anthologies::CategoryResolver
  field :stories_featured, resolver: Graph::Resolvers::Anthologies::FeaturedStoriesResolver

  field :jobs_plans, resolver: Graph::Resolvers::Jobs::Plans

  # NOTE(RAJ): Below fields can be removed when GKA editions code prior to 2022 are archived.
  field :legacy_golden_kitty, resolver: Graph::Resolvers::GoldenKitty::LegacyGoldenKittyResolver
  field :legacy_golden_kitty_categories, resolver: Graph::Resolvers::GoldenKitty::LegacyCategoryResolver

  field :golden_kitty_edition, resolver: Graph::Resolvers::GoldenKitty::Edition
  field :golden_kitty_category, resolver: Graph::Resolvers::GoldenKitty::Category
  field :golden_kitty_hof, resolver: Graph::Resolvers::GoldenKitty::HallOfFameResolver

  field :job, resolver: Graph::Resolvers::Jobs::JobResolver

  field :simple_cast_feed, resolver: Graph::Resolvers::SimpleCast

  field :maker_fest_categories, resolver: Graph::Resolvers::MakerFest::UpcomingPageResolver

  field :makers_festival_edition, resolver: Graph::Resolvers::MakersFestival::EditionResolver

  field :post_link_validate, resolver: Graph::Resolvers::Posts::LinkValidatorResolver

  field :founder_club_deals, Graph::Types::FounderClubDealType.connection_type, max_page_size: 20, resolver: Graph::Resolvers::FounderClub::SearchResolver, connection: true

  field :founder_club_deals_count, Int, null: false

  def founder_club_deals_count
    FounderClub::Deal.active.count
  end

  field :founder_club_deal, Graph::Types::FounderClubDealType, null: true do
    argument :id, ID, required: true
  end

  def founder_club_deal(id:)
    FounderClub::Deal.find_by id: id
  end

  field :founder_club_plan, resolver: Graph::Resolvers::FounderClub::Plan

  field :discussion_thread, resolver: Graph::Resolvers::Discussion::FindResolver

  field :radio_sponsor, resolver: Graph::Resolvers::Radio::Sponsor

  field :browser_extension_settings, resolver: Graph::Resolvers::BrowserExtension::Settings
  field :browser_extension_feed, resolver: Graph::Resolvers::BrowserExtension::Feed, max_page_size: 2, connection: true

  field :about_page, resolver: Graph::Resolvers::AboutPage

  field :notifications_feed, Graph::Types::Notifications::FeedItemType.connection_type, resolver: Graph::Resolvers::Notifications::Feed, connection: true, null: false

  field :topics_feed, Graph::Types::PostType.connection_type, resolver: Graph::Resolvers::Topics::FeedResolver, null: false, connection: true

  field :ph_homepage_og_image_url, String, null: true

  def ph_homepage_og_image_url
    Setting.find_by(name: 'ph_homepage_og_image_url')&.value
  end

  field :ad, resolver: Graph::Resolvers::Ads::Channel
  field :ad_preview, resolver: Graph::Resolvers::Ads::Preview

  field :social_login_requested, Boolean, null: false

  def social_login_requested
    SignIn.user_has_new_social_login_request?(context[:session])
  end

  field :page_content, resolver: Graph::Resolvers::PageContent

  field :share_text, resolver: Graph::Resolvers::ShareText

  field :moderation_product_post_completion, resolver: Graph::Resolvers::Moderation::ProductPostCompletionResolver

  field :change_log, Graph::Types::ChangeLogType, null: true do
    argument :slug, String, required: true
  end

  def change_log(slug:)
    ChangeLog::Entry.published.find_by(slug: slug)
  end

  field :change_logs, Graph::Types::ChangeLogType.connection_type, resolver: Graph::Resolvers::ChangeLogs::SearchResolver, null: false, connection: true

  field :product_request, Graph::Types::ProductRequestType, null: true do
    argument :id, ID, required: true
  end

  def product_request(id:)
    ProductRequest.find_by id: id
  end

  field :recommendation, Graph::Types::RecommendationType, null: true do
    argument :id, ID, required: true
  end

  def recommendation(id:)
    Recommendation.find_by id: id
  end

  field :recommended_product, Graph::Types::RecommendedProductType, null: true do
    argument :id, ID, required: true
  end

  def recommended_product(id:)
    RecommendedProduct.find_by id: id
  end

  field :product_requests, Graph::Types::ProductRequestType.connection_type, max_page_size: 20, resolver: Graph::Resolvers::ProductRequests::SearchResolver, null: false, connection: true

  field :discussion_categories, Graph::Types::Discussion::CategoryType.connection_type, max_page_size: 20, resolver: Graph::Resolvers::Discussion::CategoryResolver, null: false, connection: true

  field :search, resolver: Graph::Resolvers::Search::SearchableResolver
  field :post_search, resolver: Graph::Resolvers::Search::PostResolver
  field :product_search, resolver: Graph::Resolvers::Search::ProductResolver
  field :collection_search, resolver: Graph::Resolvers::Search::CollectionResolver
  field :user_search, resolver: Graph::Resolvers::Search::UserResolver
  field :trending_searches, [String], null: false do
    argument :limit, Integer
  end

  def trending_searches(limit: 5)
    Search.trending_queries(limit: limit)
  end

  field :dev_product_search, resolver: Graph::Resolvers::Search::DevProductResolver
  field :post_search_internal, resolver: Graph::Resolvers::Posts::SearchResolver
  field :user_search_internal, Graph::Types::UserType.connection_type, max_page_size: 20, resolver: Graph::Resolvers::Users::UsersSearchResolver, null: false, connection: true

  field :homefeed, resolver: Graph::Resolvers::HomefeedResolver

  field :commentable, resolver: Graph::Resolvers::Comments::Commentable

  field :products_to_review,
        Graph::Types::ProductType.connection_type,
        max_page_size: 20,
        resolver: Graph::Resolvers::Products::FindToReviewResolver,
        null: false,
        connection: true

  field :review, Graph::Types::ReviewType, null: true do
    argument :id, ID, required: true
  end

  def review(id:)
    Review.find_by id: id
  end

  field :web3_feed, resolver: Graph::Resolvers::Web3::FeedResolver

  field :banner, resolver: Graph::Resolvers::BannerResolver

  field :highlighted_change, resolver: Graph::Resolvers::HighlightedChangeResolver

  field :team_invite, Graph::Types::Team::InviteType, null: true do
    argument :code, String, required: true
  end

  def team_invite(code:)
    Team::Invite.find_by code: code
  end

  field :team_invite_users_search, resolver: Graph::Resolvers::Team::InviteUsersSearchResolver
end
