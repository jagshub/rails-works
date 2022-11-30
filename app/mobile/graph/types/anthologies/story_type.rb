# frozen_string_literal: true

module Mobile::Graph::Types
  class Anthologies::StoryType < BaseNode
    extend ::Graph::Utils::AuthorizeRead

    implements CommentableInterfaceType
    implements VotableInterfaceType

    graphql_name 'AnthologiesStory'

    field :author_name, String, null: true
    field :author_url, String, null: true
    field :body_html, HTMLType, null: true, deprecation_reason: 'Use formattedBody'
    field :body_md, String, null: true, deprecation_reason: 'Use formattedBody'
    field :body_text_preview, String, null: true
    field :formatted_body, FormattedTextType, null: true, method: :body_html
    field :can_manage, resolver: Mobile::Graph::Utils::CanResolver.build(:update)
    field :category, Mobile::Graph::Types::Anthologies::CategoryType, null: false
    field :description, String, null: true
    field :header_image_credit, String, null: true
    field :header_image_uuid, String, null: true
    field :mins_to_read, Integer, null: true
    field :published_at, DateType, null: false
    field :related_stories, resolver: Mobile::Graph::Resolvers::Stories::Related
    field :slug, String, null: false
    field :social_image_uuid, String, null: true
    field :title, String, null: false

    association :author, UserType, null: false
    association :post_mentions, [PostType], null: false
    association :user_mentions, [UserType], null: false

    def body_md
      return if object.body_html.blank?

      ::ReverseMarkdown.convert object.body_html
    end

    def body_text_preview
      ::Anthologies.story_body_preview object
    end

    def category
      ::Anthologies.story_category object.category
    end

    def published_at
      object.published_at || object.created_at
    end
  end
end
