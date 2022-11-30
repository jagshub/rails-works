# frozen_string_literal: true

module API::V2::Types
  class CommentType < BaseObject
    description 'A comment posted by a User.'

    implements VotableInterfaceType

    field :id, ID, 'ID of the comment.', null: false
    field :body, String, 'Body of the comment.', null: false
    field :url, String, 'Public URL of the comment.', null: false
    field :created_at, DateTimeType, 'Identifies the date and time when comment was created.', null: false

    field :replies, CommentType.connection_type, 'Lookup comments that were posted on the comment itself.', null: false, resolver: API::V2::Resolvers::Comments::SearchResolver

    association :user, UserType, description: 'User who posted the comment.', null: false, include_id_field: true
    association :parent, CommentType, description: 'Comment on which this comment was posted(null in case of top level comments).', null: true, include_id_field: true

    def url
      Routes.comment_url(object, url_tracking_params)
    end

    def parent_id
      object.parent_comment_id
    end
  end
end
