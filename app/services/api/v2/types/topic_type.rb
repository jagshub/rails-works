# frozen_string_literal: true

module API::V2::Types
  class TopicType < BaseObject
    description 'A topic.'

    field :id, ID, 'ID of the topic.', null: false
    field :name, String, 'Name of the topic.', null: false
    field :slug, String, 'URL friendly slug of the topic.', null: false
    field :description, String, 'Description of the topic.', null: false
    field :created_at, DateTimeType, 'Identifies the date and time when topic was created.', null: false
    field :posts_count, Int, 'Number of posts that are part of the topic.', null: false
    field :url, String, 'Public URL of the topic.', null: false
    field :image, String, 'Image of the topic.', resolver: API::V2::Resolvers::ImageResolver.generate(null: true, &:image_uuid)
    field :followers_count, Int, 'Number of users who are following the topic.', null: false
    field :is_following, Boolean, 'Whether the viewer is following the topic or not.', resolver: API::V2::Resolvers::Topics::IsFollowingResolver, complexity: 2

    def url
      Routes.topic_url(object, url_tracking_params)
    end
  end
end
