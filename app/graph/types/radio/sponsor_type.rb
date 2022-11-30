# frozen_string_literal: true

module Graph::Types
  class Radio::SponsorType < BaseNode
    graphql_name 'RadioSponsors'

    field :name, String, null: false
    field :image_uuid, String, null: false
    field :link, String, null: false
    field :image_width, Int, null: true
    field :image_height, Int, null: true
    field :image_thumbnail_width, Int, null: true
    field :image_thumbnail_height, Int, null: true
    field :image_class_name, String, null: true
  end
end
