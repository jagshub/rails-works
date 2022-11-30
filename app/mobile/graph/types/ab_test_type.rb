# frozen_string_literal: true

module Mobile::Graph::Types
  class AbTestType < BaseObject
    field :name, String, null: false
    field :variant, String, null: false
  end
end
