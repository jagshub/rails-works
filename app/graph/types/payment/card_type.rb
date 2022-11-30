# frozen_string_literal: true

module Graph::Types
  class Payment::CardType < BaseObject
    graphql_name 'PaymentCard'

    field :id, String, null: false
    field :last4, String, null: false
    field :exp_month, Int, null: false
    field :exp_year, Int, null: false
    field :brand, String, null: false
    field :customer, String, null: false
  end
end
