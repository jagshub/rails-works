# frozen_string_literal: true

module Graph::Types
  class MediaUploadType < BaseObject
    # NOTE(DZ): Uploaded media are not persisted yet and do not have an id.
    field :image_uuid, String, null: false, method: :uuid
    field :media_type, String, null: false, method: :kind
    field :original_height, Integer, null: false
    field :original_width, Integer, null: false
    field :metadata, MediaType::MediaMetadataType, null: false
  end
end
