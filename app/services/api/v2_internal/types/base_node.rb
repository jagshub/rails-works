# frozen_string_literal: true

module API::V2Internal::Types
  class BaseNode < BaseObject
    field :id, ID, null: false
  end
end
