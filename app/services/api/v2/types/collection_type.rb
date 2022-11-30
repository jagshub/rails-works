# frozen_string_literal: true

module API::V2::Types
  class CollectionType < BaseObject
    description 'A collection of posts.'

    implements TopicableInterfaceType

    field :id, ID, 'ID of the collection.', null: false
    field :name, String, 'Name of the collection.', null: false
    field :tagline, String, 'Tagline of the collection.', null: false, method: :title
    field :url, String, 'Public URL of the goal.', null: false
    field :created_at, DateTimeType, 'Identifies the date and time when collection was created.', null: false
    field :featured_at, DateTimeType, 'Identifies the date and time when collection was featured.', null: true
    field :description, String, 'Description of the collection in plain text.', null: true
    field :followers_count, Int, 'Number of users following the collection.', null: false, method: :subscriber_count
    field :cover_image, String, 'Cover image for the collection.', resolver: API::V2::Resolvers::ImageResolver.generate(null: true, &:background_image_uuid)

    field :is_following, Boolean, 'Whether the viewer is following the collection or not.', resolver: API::V2::Resolvers::Collections::IsFollowingResolver, complexity: 2
    field :posts, PostType.connection_type, 'Lookup posts which are part of the collection.', null: false

    association :user, UserType, description: 'User who created the collection.', null: false, include_id_field: true

    def url
      Routes.collection_url(object, url_tracking_params)
    end

    def posts
      Post.joins(:collection_post_associations).where("collection_post_associations.collection_id = #{ object.id }").order('votes_count DESC')
    end
  end
end
