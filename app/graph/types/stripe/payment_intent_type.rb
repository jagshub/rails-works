# frozen_string_literal: true

module Graph::Types
  class Stripe::PaymentIntentType < BaseObject
    field :subscription_id, String, null: false
    field :client_secret, String, null: false
    field :customer_id, String, null: false
  end
end
