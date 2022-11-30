# frozen_string_literal: true

module Graph::Types
  class ErrorType < BaseObject
    graphql_name 'Error'

    field :field, String, null: false
    field :messages, [String], null: false
  end
end
