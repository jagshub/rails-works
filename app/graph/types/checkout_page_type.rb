# frozen_string_literal: true

module Graph::Types
  class CheckoutPageType < BaseObject
    graphql_name 'CheckoutPage'

    field :id, ID, null: false

    field :name, String, null: false
    field :slug, String, null: false
    field :sku, String, null: false

    field :body, Graph::Types::HtmlContentType, null: true
    field :price, Int, null: false

    def price
      CheckoutPages::PaymentType.new(object).price
    end
  end
end
