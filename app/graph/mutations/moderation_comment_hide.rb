# frozen_string_literal: true

module Graph::Mutations
  class ModerationCommentHide < BaseMutation
    argument_record :comment, Comment, required: true, authorize: :moderate

    returns Graph::Types::CommentType

    def perform(comment:)
      Moderation.comment_hide(comment: comment)
      comment
    end
  end
end
