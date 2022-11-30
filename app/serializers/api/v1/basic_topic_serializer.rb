# frozen_string_literal: true

class API::V1::BasicTopicSerializer < API::V1::BaseSerializer
  delegated_attributes(
    :id,
    :name,
    :slug,
    to: :resource,
  )
end
