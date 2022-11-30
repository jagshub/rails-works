# frozen_string_literal: true

module Graph::Types
  class Payment::DiscountType < BaseObject
    graphql_name 'PaymentDiscount'

    field :percentage_off, Int, null: false
    field :code, String, null: false
    field :name, String, null: false
    field :description, String, null: true
  end
end
