# frozen_string_literal: true

module API::V2Internal::Types
  class MediaMetadataType < BaseObject
    graphql_name 'MediaMetadata'

    field :kindle_asin, String, null: true, camelize: false
    field :url, String, null: true
    field :video_id, String, null: true
  end
end

module API::V2Internal::Types
  class MediaType < BaseObject
    graphql_name 'Media'

    field :id, ID, null: false
    field :image_uuid, String, null: false, method: :uuid
    field :media_type, String, null: false, method: :kind
    field :original_height, Int, null: false
    field :original_width, Int, null: false
    field :metadata, API::V2Internal::Types::MediaMetadataType, null: true
    field :url, resolver: API::V2Internal::Resolvers::MediaImageUrlResolver

    def metadata
      object.metadata.to_h
    end
  end
end
