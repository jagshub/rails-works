# frozen_string_literal: true

module Graph::Types
  class CommentType < BaseObject
    implements Graph::Types::SeoInterfaceType
    implements Graph::Types::ShareableInterfaceType
    implements Graph::Types::VotableInterfaceType

    field :id, ID, null: false
    field :body, String, null: false
    field :can_destroy, Boolean, resolver: Graph::Resolvers::Can.build(:destroy), null: false
    field :can_edit, Boolean, resolver: Graph::Resolvers::Can.build(:edit), null: false
    field :can_reply, Boolean, resolver: Graph::Resolvers::Can.build(:reply), null: false
    field :created_at, DateTimeType, null: false
    field :is_sticky, Boolean, method: :sticky, null: false
    field :is_hidden, Boolean, method: :hidden?, null: false
    field :replies_count, Int, null: false
    field :badges, [String], null: false
    field :body_html, String, null: false
    field :body_text, String, null: false
    field :path, String, null: false
    field :replies, CommentType.connection_type, max_page_size: 20, null: false, resolver: Graph::Resolvers::Comments::RepliesResolver
    field :last_viewer_reply, resolver: Graph::Resolvers::Comments::LastViewerReply

    association :parent, CommentType, null: true
    association :subject, CommentableInterfaceType, null: false
    association :user, UserType, null: false
    association :poll, Poll::PollType, null: true
    association :review, ReviewType, null: true
    association :media, [MediaType], null: true

    def badges
      Comments::Badges.call object
    end

    def body_html
      BetterFormatter.call(object.body, mode: :full).gsub('?makers', '<a>?makers</a>')
    end

    def body_text
      ActionController::Base.helpers.strip_tags(object.body)
    end

    def path
      Routes.comment_path(object)
    end
  end
end
