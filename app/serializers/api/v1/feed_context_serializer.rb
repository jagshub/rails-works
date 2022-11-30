# frozen_string_literal: true

class API::V1::FeedContextSerializer < API::V1::BaseSerializer
  delegated_attributes(
    :type,
    to: :resource,
  )

  attributes(
    :subject,
    :user,
  )

  def subject
    {
      id: resource.subject_id,
      type: serialize_class_name(resource.subject_type),
    }
  end

  def user
    {
      id: resource.user_id,
      avatar_url: Users::Avatar.url_for_user_id(resource.user_id, size: 88),
    }
  end
end
