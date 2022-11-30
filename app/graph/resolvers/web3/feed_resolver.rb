# frozen_string_literal: true

class Graph::Resolvers::Web3::FeedResolver < Graph::Resolvers::Base
  type Graph::Types::Web3::FeedType, null: false

  def resolve
    true
  end
end
