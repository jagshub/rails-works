# frozen_string_literal: true

module Graph::Types
  class JobsDiscountPageType < BaseObject
    graphql_name 'JobsDiscountPage'

    field :id, ID, null: false
    field :slug, String, null: false
    field :name, String, null: false
    field :text, String, null: false
    field :discount_plan_ids, [Int], null: false
  end
end
