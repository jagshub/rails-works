# frozen_string_literal: true

module Mobile::Graph::Types
  class BaseNode < BaseObject
    field :id, ID, null: false

    def current_user
      context[:current_user]
    end
  end
end
