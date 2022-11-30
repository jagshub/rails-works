# frozen_string_literal: true

module Graph::Types
  class MediaInputType < BaseInputObject
    argument :id, String, required: false
    argument :image_uuid, String, required: true, camelize: true
    argument :media_type, String, required: true, camelize: true
    argument :original_height, Integer, required: true, camelize: true
    argument :original_width, Integer, required: true, camelize: true
    argument :metadata, Graph::Types::JsonType, required: true
  end
end
