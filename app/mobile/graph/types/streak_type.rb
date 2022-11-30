# frozen_string_literal: true

module Mobile::Graph::Types
  class StreakType < BaseObject
    field :duration, Int, null: false
    field :emoji, String, null: true
    field :text, String, null: true
  end
end
