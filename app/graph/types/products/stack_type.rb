# frozen_string_literal: true

module Graph::Types
  class Products::StackType < BaseNode
    graphql_name 'ProductStackType'

    field :id, ID, null: false
    association :product, Graph::Types::ProductType, null: false
    association :user, Graph::Types::UserType, null: false
  end
end
