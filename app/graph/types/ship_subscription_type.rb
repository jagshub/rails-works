# frozen_string_literal: true

module Graph::Types
  class ShipSubscriptionType < BaseObject
    graphql_name 'ShipSubscription'

    field :id, ID, null: false
    field :in_trial, Boolean, method: :trial?, null: false
    field :trial_ended, Boolean, method: :trial_ended?, null: false
    field :billing_plan, String, null: false
    field :billing_period, String, null: false
  end
end
