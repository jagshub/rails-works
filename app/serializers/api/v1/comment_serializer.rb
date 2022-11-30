# frozen_string_literal: true

class API::V1::CommentSerializer < API::V1::BasicCommentSerializer
  attributes :post, :user

  # Note(andreasklinger): By default we just embed the user, unless otherwise requested
  def post
    return {} if exclude?(:post) || resource.subject_type != 'Post'

    API::V1::BasicPostSerializer.new(resource.subject, scope)
  end

  def user
    return {} if scope[:exclude].present? && scope[:exclude].include?(:user)

    API::V1::BasicUserSerializer.new(resource.user, scope)
  end
end
