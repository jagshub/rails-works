# frozen_string_literal: true

class Graph::Resolvers::Products::TopProductsResolver < Graph::Resolvers::Base
  class VariantType < Graph::Types::BaseEnum
    graphql_name 'TopProductsCardVariant'

    TrendingPosts::VARIANTS.keys.each do |variant|
      value variant
    end
  end

  class TopProductsCardType < Graph::Types::BaseObject
    graphql_name 'TopProductsCard'

    field :variant, VariantType, null: false
    field :products, [Graph::Types::ProductType], null: false
  end

  type TopProductsCardType, null: false

  argument :preferred_variant, VariantType, required: true
  argument :exclude_ids, [ID], required: false

  def resolve(preferred_variant:, exclude_ids: nil)
    trending_posts = TrendingPosts.data_for(preferred_variant: preferred_variant, exclude_product_ids: exclude_ids, user: current_user, limit: 10)

    OpenStruct.new(
      variant: trending_posts.variant,
      products: Product.by_ordered_ids(trending_posts.posts.map { |p| p.new_product&.id }.compact),
    )
  end
end
