# frozen_string_literal: true

class API::V1::TopicSerializer < API::V1::BasicTopicSerializer
  delegated_attributes(
    :created_at,
    :description,
    :followers_count,
    :posts_count,
    :updated_at,
    to: :resource,
  )

  attributes(
    :image,
    :trending,
  )

  def image
    ::Image.call ::Topics::ImageUuid.call(resource)
  end

  def trending
    false
  end
end
