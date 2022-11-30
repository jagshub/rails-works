# frozen_string_literal: true

module Mobile::Graph::Types
  class MediaType < BaseObject
    class MediaMetadataType < BaseObject
      field :url, String, null: true
      field :platform, String, null: true
      field :video_id, String, null: true
    end

    field :image_uuid, String, null: false, method: :uuid
    field :media_type, String, null: false, method: :kind
    field :original_height, Integer, null: false
    field :original_width, Integer, null: false
    field :metadata, MediaMetadataType, null: false
  end
end
