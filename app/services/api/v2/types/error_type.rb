# frozen_string_literal: true

module API::V2::Types
  class ErrorType < BaseObject
    field :field, String, 'Field for which the error occurred.', null: false
    field :message, String, 'Error message.', null: false
  end
end
