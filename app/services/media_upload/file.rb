# frozen_string_literal: true

module MediaUpload
  class File
    attr_reader :image_uuid, :original_width, :original_height, :media_type, :metadata

    def initialize(image_uuid:, original_width:, original_height:, media_type:, metadata: nil)
      @image_uuid = image_uuid
      @original_width = original_width
      @original_height = original_height
      @media_type = media_type
      @metadata = metadata || {}
    end

    def to_h
      {
        image_uuid: image_uuid,
        original_width: original_width,
        original_height: original_height,
        media_type: media_type.to_s,
        metadata: metadata || {},
      }
    end

    def id
      nil
    end

    # NOTE(DZ): Support graphql `MediaType`
    def uuid
      image_uuid
    end

    def kind
      media_type
    end

    def cache_key
      "media/new/#{ image_uuid }"
    end
  end
end
