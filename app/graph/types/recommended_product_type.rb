# frozen_string_literal: true

module Graph::Types
  class RecommendedProductType < BaseObject
    graphql_name 'RecommendedProduct'

    implements Graph::Types::VotableInterfaceType

    field :id, ID, null: false
    field :name, String, null: true, method: :name_with_fallback
    field :recommendations, Graph::Types::RecommendationType.connection_type, max_page_size: 20, resolver: Graph::Resolvers::RecommendedProducts::RecommendationsResolver, null: false, connection: true

    association :product, Graph::Types::ProductType, null: false
    association :product_request, Graph::Types::ProductRequestType, null: false
  end
end
