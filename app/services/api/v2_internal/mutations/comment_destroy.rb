# frozen_string_literal: true

module API::V2Internal::Mutations
  class CommentDestroy < BaseMutation
    node :comment, type: ::Comment

    returns API::V2Internal::Types::CommentType

    def perform
      ::Comments.destroy(comment: node, user: current_user)

      node
    end
  end
end
