# frozen_string_literal: true

class API::V2Internal::Query < API::V2Internal::Types::BaseObject
  field :post, resolver: API::V2Internal::Resolvers::Posts::FindResolver

  field :posts, API::V2Internal::Types::PostType.connection_type, max_page_size: 30, resolver: API::V2Internal::Resolvers::PostsResolver, connection: true

  field :search_posts, API::V2Internal::Types::Search::PostConnectionType, max_page_size: 20, resolver: API::V2Internal::Resolvers::Posts::ExternalPostsSearchResolver, connection: true, camelize: false, null: false

  field :user, resolver: API::V2Internal::Resolvers::UserResolver

  field :collection, resolver: API::V2Internal::Resolvers::Collections::CollectionResolver

  field :collections, API::V2Internal::Types::CollectionType.connection_type, max_page_size: 30, resolver: API::V2Internal::Resolvers::Collections::CollectionsResolver, null: false, connection: true

  field :activity_feed, API::V2Internal::Types::ActivityItemType.connection_type, max_page_size: 20, resolver: API::V2Internal::Resolvers::ActivityFeedResolver, connection: true

  field :ad, resolver: API::V2Internal::Resolvers::Ads::ChannelResolver, null: false

  field :promoted_email_campaign, resolver: API::V2Internal::Resolvers::Ads::PromotedEmailCampaignResolver

  field :share_text, resolver: API::V2Internal::Resolvers::ShareTextResolver

  field :viewer, API::V2Internal::Types::ViewerType, null: true

  field :launch_day_posts, [API::V2Internal::Types::PostType], null: false, resolver: API::V2Internal::Resolvers::LaunchDayPostsResolver

  def viewer
    context[:current_user]
  end
end
