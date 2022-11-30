# frozen_string_literal: true

module Graph::Types
  class Seo::QueryType < BaseObject
    graphql_name 'SeoQuery'

    field :id, ID, null: false
    field :query, String, null: false
    field :position, Int, null: false
    field :ctr, Float, null: false
  end
end
