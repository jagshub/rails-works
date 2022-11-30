# frozen_string_literal: true

module Graph::Types
  class Payment::PlanType < BaseObject
    graphql_name 'PaymentPlan'

    field :id, ID, null: false
    field :name, String, null: false
    field :project, String, null: false
    field :amount_in_cents, Int, null: false
    field :period_in_months, Int, null: false
  end
end
