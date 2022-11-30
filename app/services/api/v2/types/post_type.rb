# frozen_string_literal: true

module API::V2::Types
  class PostType < BaseObject
    description 'A post.'

    implements VotableInterfaceType
    implements TopicableInterfaceType

    field :id, ID, 'ID of the Post.', null: false
    field :name, String, 'Name of the Post.', null: false
    field :slug, String, 'URL friendly slug of the Post.', null: false
    field :tagline, String, 'Tagline of the Post.', null: false
    field :comments_count, Int, 'Number of comments made on the Post.', null: false
    field :created_at, DateTimeType, 'Identifies the date and time when the Post was created.', null: false
    field :featured_at, DateTimeType, 'Identifies the date and time when the Post was featured.', null: true
    field :description, String, 'Description of the Post in plain text.', null: true, method: :description_text
    field :url, String, 'URL of the Post on Product Hunt.', null: false
    field :website, String, "URL that redirects to the Post's website.", null: false
    field :reviews_rating, Float, 'Aggregate review rating for the Post.', null: false
    field :reviews_count, Int, 'Count of review for the Post', null: false

    field :is_collected, Boolean, 'Whether the viewer has added the Post to one of their collections.', resolver: API::V2::Resolvers::Posts::IsCollectedResolver, complexity: 2

    field :collections, CollectionType.connection_type, 'Lookup collections which the Post is part of.', null: false
    field :comments, CommentType.connection_type, 'Lookup comments on the Post.', null: false, resolver: API::V2::Resolvers::Comments::SearchResolver

    field :thumbnail,
          API::V2::Types::MediaType,
          'Thumbnail media object of the Post.',
          null: true,
          resolver: Posts::TemporaryMediaResolver,
          extras: [:graphql_name]

    association :user, UserType, description: 'User who created the Post.', null: false, include_id_field: true
    association :makers, [UserType], description: 'Users who are marked as makers of the Post.', null: false
    association :media, [MediaType], description: 'Media items for the Post.', null: false

    field :product_links, [ProductLinkType], description: 'Additional product links', null: false, method: :links

    def url
      Routes.post_url(object, url_tracking_params)
    end

    def website
      Routes.short_link_url(object.short_code, url_tracking_params)
    end

    def collections
      object.collections.by_subscriber_count
    end

    def created_at
      object.scheduled_at || object.created_at
    end
  end
end
