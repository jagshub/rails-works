# frozen_string_literal: true

class API::Widgets::Cards::V1::MediaSerializer < BaseSerializer
  self.root = false

  delegated_attributes(
    :id,
    :metadata,
    :original_height,
    :original_width,
    to: :resource,
  )

  delegate :cache_key, to: :resource

  attributes :image_uuid, :media_type

  def image_uuid
    resource.uuid
  end

  def media_type
    resource.kind
  end
end
