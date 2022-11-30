# frozen_string_literal: true

module Graph::Types
  class CheckoutPageLogType < BaseObject
    graphql_name 'CheckoutPageLog'

    field :id, ID, null: false
  end
end
