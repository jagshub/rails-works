# frozen_string_literal: true

module Graph::Types
  class Newsletter::SponsorType < BaseNode
    field :image_uuid, String, null: false
    field :link, String, null: false
    field :cta, String, null: true
    field :description_html, String, null: false
    field :body_image_uuid, String, null: true
  end
end
