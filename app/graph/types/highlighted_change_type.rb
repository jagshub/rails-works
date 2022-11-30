# frozen_string_literal: true

module Graph::Types
  class HighlightedChangeType < BaseNode
    field :title, String, null: false
    field :body, String, null: false
    field :cta_url, String, null: true
    field :cta_text, String, null: true
    field :desktop_image_uuid, String, null: true
    field :tablet_image_uuid, String, null: true
    field :mobile_image_uuid, String, null: true
  end
end
