# frozen_string_literal: true

module Mobile::Graph::Types
  class CollectionPostType < BaseNode
    graphql_name 'CollectionPost'

    association :post, Mobile::Graph::Types::PostType, null: false
  end
end
