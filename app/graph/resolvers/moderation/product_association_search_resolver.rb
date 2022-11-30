# frozen_string_literal: true

class Graph::Resolvers::Moderation::ProductAssociationSearchResolver < Graph::Resolvers::Base
  type Graph::Types::ProductType.connection_type, null: false

  argument :product_id, ID, required: true
  argument :query, String, required: true

  def resolve(product_id:, query:)
    return [] if query.blank?

    product = Product.find(product_id)

    exclude_ids = product.associated_product_ids
    exclude_ids << product.id

    Search.query_product(query, exclude_ids: exclude_ids)
  end
end
