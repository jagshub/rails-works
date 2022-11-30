# frozen_string_literal: true

module Graph::Types
  class HomefeedPageType < BaseNode
    field :title, String, null: true
    field :subtitle, String, null: true
    field :items, [HomefeedItemType], null: false
    field :hide_after, Integer, null: true
    field :date, Graph::Types::DateTimeType, null: true
    field :coming_soon, [Graph::Types::Upcoming::EventType], null: false
  end
end
