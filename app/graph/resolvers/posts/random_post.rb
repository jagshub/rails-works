# frozen_string_literal: true

class Graph::Resolvers::Posts::RandomPost < Graph::Resolvers::Base
  type Graph::Types::PostType, null: true

  def resolve
    Post.where(product_state: :default)
        .between_dates(3.months.ago, 7.days.ago)
        .where('posts.credible_votes_count >= ?', 100)
        .not_trashed
        .by_random
        .first
  end
end
