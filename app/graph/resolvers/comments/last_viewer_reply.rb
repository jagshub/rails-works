# frozen_string_literal: true

class Graph::Resolvers::Comments::LastViewerReply < Graph::Resolvers::Base
  type Graph::Types::CommentType, null: true

  def resolve
    return unless context[:current_user]

    Loader.for(context[:current_user]).load(object)
  end

  class Loader < GraphQL::Batch::Loader
    def initialize(user)
      @user = user
    end

    def perform(comments)
      parent_ids = comments.map { |comment| comment.parent_comment_id || comment.id }

      replies = Comment.visible.where(parent_comment_id: parent_ids, user_id: @user.id).group_by(&:parent_comment_id)

      comments.each do |comment|
        fulfill(comment, replies[comment.parent_comment_id || comment.id]&.last)
      end
    end
  end
end
