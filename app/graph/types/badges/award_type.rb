# frozen_string_literal: true

module Graph::Types
  class Badges::AwardType < BaseObject
    graphql_name 'Award'

    field :id, ID, null: false
    field :name, String, null: false
    field :description, String, null: false
    field :image_uuid, String, null: false
  end
end
