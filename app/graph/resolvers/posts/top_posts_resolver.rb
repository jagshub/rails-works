# frozen_string_literal: true

class Graph::Resolvers::Posts::TopPostsResolver < Graph::Resolvers::Base
  class VariantType < Graph::Types::BaseEnum
    graphql_name 'TopPostsCardVariant'

    TrendingPosts::VARIANTS.keys.each do |variant|
      value variant
    end
  end

  class TopPostsCardType < Graph::Types::BaseObject
    graphql_name 'TopPostsCard'

    field :variant, VariantType, null: false
    field :posts, [Graph::Types::PostType], null: false
  end

  type TopPostsCardType, null: false

  argument :preferred_variant, VariantType, required: true

  def resolve(preferred_variant:)
    TrendingPosts.data_for(preferred_variant: preferred_variant, user: current_user)
  end
end
