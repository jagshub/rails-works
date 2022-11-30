# frozen_string_literal: true

module Mobile::Graph::Types
  class TopicType < BaseNode
    field :name, String, null: false
    field :slug, String, null: false
    field :emoji, String, null: true
    field :description, String, null: true
    field :image_uuid, String, null: true
    field :is_followed, resolver: Mobile::Graph::Resolvers::Topics::IsFollowed
    field :posts, resolver: Mobile::Graph::Resolvers::Topics::Posts
    field :posts_count, Int, null: false
    field :stories_count, Int, null: false

    def image_uuid
      Rails.cache.fetch([:graphql, :topic_image, object.id], expires_in: 1.day) { ::Topics::ImageUuid.call(object) }
    end
  end
end
