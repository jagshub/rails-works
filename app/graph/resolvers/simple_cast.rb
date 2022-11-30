# frozen_string_literal: true

class Graph::Resolvers::SimpleCast < Graph::Resolvers::Base
  class FeedType < Graph::Types::BaseEnum
    graphql_name 'SimpleCastFeedType'

    value 'all'
    value 'ge'
  end

  argument :feed_type, FeedType, required: false
  argument :first, Int, required: false

  type [Graph::Types::SimpleCastEpisodeType], null: false

  def resolve(args = {})
    External::SimpleCastApi.podcast_feed(args[:feed_type], args[:first])
  end
end
