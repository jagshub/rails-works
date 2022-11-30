# frozen_string_literal: true

module Graph::Types
  class Products::ScreenshotType < BaseObject
    graphql_name 'ProductScreenshot'

    field :id, ID, null: false
    field :image_uuid, String, null: false
    field :alt_text, String, null: true
    field :position, Integer, null: false
  end
end
