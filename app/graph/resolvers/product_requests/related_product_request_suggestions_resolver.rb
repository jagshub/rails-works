# frozen_string_literal: true

class Graph::Resolvers::ProductRequests::RelatedProductRequestSuggestionsResolver < Graph::Resolvers::BaseSearch
  scope do
    related_product_request_ids = object.related_product_request_ids
    excluded_related_product_request_ids = related_product_request_ids + [object.id]

    related_product_request_suggestion_ids = ProductRequestRelatedProductRequestAssociation
                                             .where(product_request: related_product_request_ids)
                                             .where.not(related_product_request_id: excluded_related_product_request_ids)
                                             .pluck(Arel.sql('DISTINCT related_product_request_id'))

    ProductRequest
      .visible
      .where(id: related_product_request_suggestion_ids)
  end
end
