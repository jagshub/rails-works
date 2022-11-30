# frozen_string_literal: true

module API::V2Internal::Types
  class ErrorType < BaseObject
    graphql_name 'Error'

    field :field, String, null: false
    field :messages, [String], null: false
  end
end
