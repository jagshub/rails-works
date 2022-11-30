# frozen_string_literal: true

module Graph::Types
  class ShipInviteCodeType < BaseObject
    graphql_name 'ShipInviteCode'

    field :id, ID, null: false
    field :code, String, null: false
    field :description, String, null: false
    field :discount_value, Int, null: true
  end
end
