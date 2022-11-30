# frozen_string_literal: true

class Graph::Resolvers::Moderation::ProductPostCompletionResolver < Graph::Resolvers::Base
  type Graph::Types::PostType.connection_type, null: false

  argument :product_id, ID, required: true
  argument :query, String, required: true

  def resolve(product_id:, query:)
    posts = Post.not_trashed.featured

    posts = posts.where '(LOWER(name) LIKE :query)', query: LikeMatch.simple(query.strip)

    posts = posts.left_joins(:product_association)
    posts = posts.where(%(
      product_post_associations.product_id IS NULL OR
      product_post_associations.product_id != ?
    ), product_id)

    posts
  end
end
