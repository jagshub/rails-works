# frozen_string_literal: true

class API::V1::MediaSerializer < API::V1::BaseSerializer
  delegated_attributes(
    :id,
    :kindle_asin,
    :priority,
    :platform,
    :video_id,
    :original_width,
    :original_height,
    :metadata,
    to: :resource,
  )

  attributes :image_url, :media_type

  delegate :image_url, to: :resource

  def media_type
    resource.kind
  end
end
