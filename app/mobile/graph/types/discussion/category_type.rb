# frozen_string_literal: true

module Mobile::Graph::Types
  class Discussion::CategoryType < BaseNode
    graphql_name 'DiscussionCategory'

    field :name, String, null: false
    field :slug, String, null: false
    field :description, String, null: true
    field :thumbnail_uuid, String, null: true
  end
end
