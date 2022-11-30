# frozen_string_literal: true

module Mobile::Graph::Types
  class HomefeedPageType < BaseNode
    field :title, String, null: true
    field :subtitle, String, null: true
    field :items, [HomefeedItemType], null: false
    field :hide_after, Integer, null: true
  end
end
