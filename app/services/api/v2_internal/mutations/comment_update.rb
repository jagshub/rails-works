# frozen_string_literal: true

module API::V2Internal::Mutations
  class CommentUpdate < BaseMutation
    argument :body, String, required: false

    node :comment, type: Comment

    returns API::V2Internal::Types::CommentType

    def perform
      form = ::Comments::UpdateForm.new(comment: node, user: current_user, request_info: request_info)
      form.update inputs
      form
    end
  end
end
