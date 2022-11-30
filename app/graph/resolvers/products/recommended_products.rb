# frozen_string_literal: true

class Graph::Resolvers::Products::RecommendedProducts < Graph::Resolvers::Base
  type [Graph::Types::ProductType], null: false

  argument :limit, Integer, required: false

  def resolve(limit: 8)
    object.related_products.live.by_credible_votes.limit(limit)
  end
end
