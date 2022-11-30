# frozen_string_literal: true

module Mobile::Graph::Resolvers
  class Posts::RelatedPosts < BaseResolver
    type [Mobile::Graph::Types::PostType], null: false

    def resolve(limit: 8)
      return [] if object.new_product.blank?

      Post.joins(:new_product)
          .where(products: { id: object.new_product.associated_products })
          .alive
          .visible
          .by_credible_votes
          .limit(limit)
    end
  end
end
