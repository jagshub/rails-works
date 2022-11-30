# frozen_string_literal: true

module API::V2Internal::Types
  class CommentType < BaseObject
    graphql_name 'Comment'

    implements API::V2Internal::Types::VotableInterfaceType

    field :id, ID, null: false
    field :body, String, null: false
    field :subject_id, ID, null: false
    field :parent_comment_id, ID, null: true
    field :created_at, API::V2Internal::Types::DateTimeType, null: false
    field :votes_count, Int, null: false
    field :replies_count, Int, null: false

    field :can_comment, resolver: ::Graph::Resolvers::Can.build(:new) { |obj| Comment.new(subject: obj) }
    field :can_reply, resolver: ::Graph::Resolvers::Can.build(:reply)
    field :can_edit, resolver: ::Graph::Resolvers::Can.build(:edit)
    field :can_destroy, resolver: ::Graph::Resolvers::Can.build(:destroy)

    field :replies, API::V2Internal::Types::CommentType.connection_type, null: false, max_page_size: 50, method: :children, connection: true

    association :user, API::V2Internal::Types::UserType, null: false
    association :poll, API::V2Internal::Types::Poll::PollType, null: true
  end
end
