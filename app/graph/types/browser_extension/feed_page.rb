# frozen_string_literal: true

module Graph::Types
  class BrowserExtension::FeedPage < BaseObject
    field :id, ID, null: false
    field :date, Graph::Types::DateTimeType, null: false
    field :cutoff_index, Integer, null: false
    field :posts_count, Integer, null: false
    field :posts, Graph::Types::PostType.connection_type, null: false
  end
end
