# frozen_string_literal: true

module Mobile::Graph::Types
  class CommentType < BaseNode
    implements Mobile::Graph::Types::VotableInterfaceType

    field :id, ID, null: false
    field :body, String, null: false, deprecation_reason: 'Use formattedBody'
    field :body_html, String, resolver: Mobile::Graph::Resolvers::Comments::BodyHTML, null: false, deprecation_reason: 'Use formattedBody'
    field :body_md, String, resolver: Mobile::Graph::Resolvers::Comments::BodyMD, null: false, deprecation_reason: 'Use formattedBody'
    field :body_text, String, null: false, deprecation_reason: 'Use formattedBody'
    field :formatted_body, FormattedTextType, null: false, method: :body
    field :can_destroy, Boolean, resolver: Mobile::Graph::Utils::CanResolver.build(:destroy), null: false
    field :can_edit, Boolean, resolver: Mobile::Graph::Utils::CanResolver.build(:edit), null: false
    field :can_reply, Boolean, resolver: Mobile::Graph::Utils::CanResolver.build(:reply), null: false
    field :created_at, DateTimeType, null: false
    field :is_sticky, Boolean, method: :sticky, null: false
    field :is_hidden, Boolean, method: :hidden?, null: false
    field :replies, resolver: Mobile::Graph::Resolvers::Comments::Replies, max_page_size: 100
    field :replies_count, Int, null: false

    association :user, UserType, null: false
    association :poll, PollType, null: true
    association :subject, CommentableInterfaceType, null: false
    association :media, [MediaType], preload: :media, null: true

    def body_text
      ActionController::Base.helpers.strip_tags(object.body)
    end

    def path
      Routes.comment_path(object)
    end
  end
end
