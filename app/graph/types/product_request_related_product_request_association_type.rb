# frozen_string_literal: true

module Graph::Types
  class ProductRequestRelatedProductRequestAssociationType < BaseObject
    graphql_name 'ProductRequestRelatedProductRequestAssociation'

    field :id, ID, null: false
    association :product_request, Graph::Types::ProductRequestType, null: false
    association :related_product_request, Graph::Types::ProductRequestType, null: false
  end
end
