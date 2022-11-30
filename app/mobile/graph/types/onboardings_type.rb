# frozen_string_literal: true

module Mobile::Graph::Types
  class OnboardingsType < BaseObject
    field :id, ID, null: true
    field :status, String, null: true
    field :step, String, null: true
  end
end
