# frozen_string_literal: true

module Graph::Types
  class ShipType < BaseObject
    graphql_name 'Ship'

    field :billing_plan, String, null: true
    field :billing_period, String, null: true
    field :discount, Int, null: true
    field :cancelled_billing_plan, String, null: true
    field :ends_at, Graph::Types::DateTimeType, null: true
    field :ended, Boolean, null: true
    field :in_trial, Boolean, null: true
    field :trial_ended, Boolean, null: true
  end
end
