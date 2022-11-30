# frozen_string_literal: true

module Graph::Mutations
  class ModerationCommentUnhide < BaseMutation
    argument_record :comment, Comment, required: true, authorize: :moderate

    returns Graph::Types::CommentType

    def perform(comment:)
      Moderation.comment_unhide(comment: comment)
      comment
    end
  end
end
