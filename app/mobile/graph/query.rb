# frozen_string_literal: true

class Mobile::Graph::Query < Mobile::Graph::Types::BaseObject
  field :ad, resolver: Mobile::Graph::Resolvers::Ads::Channel

  field :collection, resolver: Mobile::Graph::Resolvers::Collection
  field :collections, resolver: Mobile::Graph::Resolvers::Collections::SearchResolver
  field :collection_search, resolver: Mobile::Graph::Resolvers::Search::CollectionResolver

  field :comment, resolver: Mobile::Graph::Resolvers::Comments::Find

  field :discussion, resolver: Mobile::Graph::Resolvers::Discussions::Find
  field :discussions, resolver: Mobile::Graph::Resolvers::Discussions::Search
  field :discussion_search, resolver: Mobile::Graph::Resolvers::Search::DiscussionResolver

  field :discussion_categories, [Mobile::Graph::Types::Discussion::CategoryType], null: false

  field :features, [String], null: false
  field :ab_test, resolver: Mobile::Graph::Resolvers::AbTestResolver
  field :ab_test_active_participations, [Mobile::Graph::Types::AbTestType], null: false

  field :homefeed, resolver: Mobile::Graph::Resolvers::Homefeed

  field :notifications_feed, resolver: Mobile::Graph::Resolvers::Notifications::Feed

  field :stories, resolver: Mobile::Graph::Resolvers::Stories::Search
  field :stories_featured, resolver: Mobile::Graph::Resolvers::Stories::Featured
  field :story, resolver: Mobile::Graph::Resolvers::SlugOrId.build(Anthologies::Story, Mobile::Graph::Types::Anthologies::StoryType)
  field :story_categories, [String], null: false

  field :topic, Mobile::Graph::Types::TopicType, resolver: Mobile::Graph::Resolvers::SlugOrId.build(Topic)
  field :topics, Mobile::Graph::Types::TopicType.connection_type, null: false

  field :post, Mobile::Graph::Types::PostType, resolver: Mobile::Graph::Resolvers::SlugOrId.build(Post)
  field :posts, resolver: Mobile::Graph::Resolvers::Posts::Search
  field :post_search, resolver: Mobile::Graph::Resolvers::Search::PostResolver
  field :search, resolver: Mobile::Graph::Resolvers::Search::SearchableResolver

  field :user, Mobile::Graph::Types::UserType, null: true do
    argument :username, String, required: true
  end
  field :user_search, resolver: Mobile::Graph::Resolvers::Search::UserResolver
  field :users_suggested, resolver: Mobile::Graph::Resolvers::Users::UsersSuggested

  field :viewer, Mobile::Graph::Types::ViewerType, null: true

  field :media_direct_upload, Mobile::Graph::Types::AWSDirectUploadUrlType, resolver: Mobile::Graph::Resolvers::AWSDirectUploadUrlResolver

  field :search_trending, [String], 'Returns trending searches', null: false

  field :version_requirements, resolver: Mobile::Graph::Resolvers::VersionRequirements

  field :product, resolver: Mobile::Graph::Resolvers::SlugOrId.build(Product, Mobile::Graph::Types::ProductType)
  field :product_search, resolver: Mobile::Graph::Resolvers::Search::ProductResolver

  def search_trending
    Setting.find_by(name: 'trending_searches')&.value&.split(',')&.map(&:lstrip).presence || []
  end

  def discussion_categories
    Discussion::Category.having_discussions
  end

  def story_categories
    Anthologies::Story.categories.keys
  end

  def topics
    Topic.by_followers_count.by_name
  end

  def features
    Features.enabled_features(context[:current_user])
  end

  def user(username:)
    User.find_by(username: username.downcase)
  end

  def ab_test_active_participations
    AbTest.active_tests_for(ctx: context)
  end

  def viewer
    context[:current_user]
  end
end
