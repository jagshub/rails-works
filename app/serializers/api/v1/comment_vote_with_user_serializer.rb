# frozen_string_literal: true

class API::V1::CommentVoteWithUserSerializer < API::V1::BaseSerializer
  delegated_attributes :id, :created_at, :user_id, to: :resource

  attributes :comment_id, :user

  def comment_id
    resource.subject_id
  end

  def user
    API::V1::BasicUserSerializer.new(resource.user, scope)
  end
end
