# frozen_string_literal: true

module Graph::Types
  class Payment::IntentType < BaseObject
    graphql_name 'PaymentIntent'

    field :id, ID, null: false
    field :client_secret, String, null: false
    field :amount, Int, null: false
  end
end
