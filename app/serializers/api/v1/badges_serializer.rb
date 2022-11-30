# frozen_string_literal: true

class API::V1::BadgesSerializer < API::V1::BaseSerializer
  delegated_attributes(
    :id,
    :type,
    :data,
    to: :resource,
  )
end
