# frozen_string_literal: true

module Graph::Types
  class Anthologies::CategoryType < BaseObject
    field :name, String, null: false
    field :description, String, null: false
    field :slug, String, null: false
    field :stories, Graph::Types::Anthologies::StoryType.connection_type, max_page_size: 20, null: false, connection: true
  end
end
