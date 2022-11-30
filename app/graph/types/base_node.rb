# frozen_string_literal: true

module Graph::Types
  class BaseNode < BaseObject
    field :id, ID, null: false
  end
end
