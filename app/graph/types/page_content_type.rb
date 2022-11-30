# frozen_string_literal: true

module Graph::Types
  class PageContentType < BaseNode
    field :element_key, String, null: false
    field :content, String, null: true
    field :image_uuid, String, null: true
  end
end
