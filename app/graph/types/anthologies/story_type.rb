# frozen_string_literal: true

module Graph::Types
  class Anthologies::StoryType < BaseNode
    extend Graph::Utils::AuthorizeRead

    implements CommentableInterfaceType
    implements SeoInterfaceType
    implements ShareableInterfaceType
    implements VotableInterfaceType

    graphql_name 'AnthologiesStory'

    field :title, String, null: false
    field :slug, String, null: false
    field :mins_to_read, Integer, null: true
    field :description, String, null: true
    field :header_image_uuid, String, null: true
    field :social_image_uuid, String, null: true
    field :header_image_credit, String, null: true
    field :body_html, HTMLType, null: true
    field :body_text_preview, String, null: true
    field :category, Graph::Types::Anthologies::CategoryType, null: false
    association :post_mentions, [PostType], null: false
    association :user_mentions, [UserType], null: false
    association :product_mentions, [ProductType], null: false
    field :published_at, DateType, null: false

    field :related_stories, Anthologies::StoryType.connection_type,
          resolver: Graph::Resolvers::Anthologies::RelatedStoriesResolver, null: false,
          max_page_size: 5,
          connection: true

    association :author, UserType, null: false

    field :author_name, String, null: true
    field :author_url, String, null: true

    field :can_manage, resolver: Graph::Resolvers::Can.build(:update)

    field :more_stories, resolver: Graph::Resolvers::Anthologies::MoreStoriesResolver

    def body_text_preview
      ::Anthologies.story_body_preview object
    end

    def category
      ::Anthologies.story_category object.category
    end

    def more_stories(limit:)
      ::Anthologies::Story
        .published
        .by_published_at
        .where.not(id: object.id)
        .limit(limit)
    end

    def published_at
      object.published_at || object.created_at
    end
  end
end
