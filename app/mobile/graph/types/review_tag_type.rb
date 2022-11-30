# frozen_string_literal: true

module Mobile::Graph::Types
  class ReviewTagType < BaseNode
    graphql_name 'ReviewTag'

    field :id, ID, null: false
    field :property, String, null: false
    field :positive_label, String, null: true
    field :negative_label, String, null: true
  end
end
