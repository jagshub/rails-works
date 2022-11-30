# frozen_string_literal: true

class API::V1::ExternalLinkSerializer < API::V1::BaseSerializer
  delegated_attributes(
    :id,
    :title,
    :description,
    :author,
    :source,
    :url,
    :favicon_image_uuid,
    :link_type,
    to: :resource,
  )
end
