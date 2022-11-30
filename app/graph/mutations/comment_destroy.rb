# frozen_string_literal: true

module Graph::Mutations
  class CommentDestroy < BaseMutation
    argument_record :comment, Comment

    returns Graph::Types::CommentType

    require_current_user

    def perform(comment:)
      ::Comments.destroy(comment: comment, user: current_user)

      comment
    end
  end
end
