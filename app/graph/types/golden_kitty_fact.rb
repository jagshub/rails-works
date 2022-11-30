# frozen_string_literal: true

module Graph::Types
  class GoldenKittyFact < BaseObject
    graphql_name 'GoldenKittyFact'

    field :id, ID, null: false
    field :description, String, null: false
    field :image_uuid, String, null: false
  end
end
