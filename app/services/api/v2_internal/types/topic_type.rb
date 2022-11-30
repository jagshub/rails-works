# frozen_string_literal: true

module API::V2Internal::Types
  class TopicType < BaseObject
    graphql_name 'Topic'

    field :id, ID, null: false
    field :name, String, null: false
    field :slug, String, null: false
    field :description, String, null: true
  end
end
