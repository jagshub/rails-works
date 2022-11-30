# frozen_string_literal: true

module Graph::Types
  class GoldenKittySponsorType < BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :description, String, null: false
    field :url, String, null: false
    field :website, String, null: false
    field :dark_ui, Boolean, null: false
    field :bg_color, String, null: true
    field :logo_uuid, String, null: false
    field :right_image_uuid, String, null: true
    field :left_image_uuid, String, null: true
  end
end
