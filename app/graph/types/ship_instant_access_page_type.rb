# frozen_string_literal: true

module Graph::Types
  class ShipInstantAccessPageType < BaseObject
    graphql_name 'ShipInstantAccessPage'

    implements Graph::Types::SeoInterfaceType

    field :id, ID, null: false
    field :name, String, null: false
    field :slug, String, null: false
    field :text, String, null: true
    field :billing_periods, String, null: false

    association :ship_invite_code, Graph::Types::ShipInviteCodeType, null: true
  end
end
