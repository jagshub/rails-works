# frozen_string_literal: true

module Graph::Types
  class TopicType < BaseObject
    implements Graph::Types::SeoInterfaceType
    implements Graph::Types::FollowableInterfaceType
    implements Graph::Types::ShareableInterfaceType

    field :id, ID, null: false
    field :name, String, null: false
    field :kind, String, null: true
    field :slug, String, null: false
    field :emoji, String, null: true
    field :description, String, null: true
    field :posts_count, Int, null: false
    field :stories_count, Int, null: false
    field :is_followed, resolver: Graph::Resolvers::Topics::HasFollowedResolver, null: false
    field :image_uuid, String, null: true
    field :posts, Graph::Types::PostType.connection_type, max_page_size: 20, resolver: Graph::Resolvers::Topics::TopicPostsResolver, null: true, connection: true
    field :related_topics, [Graph::Types::TopicType], null: false do
      argument :limit, Int, required: false
    end

    association :parent, Graph::Types::TopicType, null: true
    association :sub_topics, [Graph::Types::TopicType], null: false

    field :related_ad,
          Graph::Types::Ads::ChannelType,
          camelize: true,
          resolver: Graph::Resolvers::Ads::Channel,
          null: true

    def image_uuid
      Rails.cache.fetch([:graphql, :topic_image, object.id], expires_in: 1.day) { ::Topics::ImageUuid.call(object) }
    end

    def related_topics(limit: 5)
      topic_ids = Rails.cache.fetch([:graphql, :related_topics, object.id, limit], expires_in: 1.day) do
        ::Topics::RelatedTopics.call(object, limit: limit).pluck(:id)
      end

      Topic.where(id: topic_ids)
    end
  end
end
