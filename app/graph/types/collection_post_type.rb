# frozen_string_literal: true

module Graph::Types
  class CollectionPostType < BaseObject
    graphql_name 'CollectionPost'

    field :id, ID, null: false
    association :post, Graph::Types::PostType, null: false
  end
end
