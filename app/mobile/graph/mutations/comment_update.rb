# frozen_string_literal: true

module Mobile::Graph::Mutations
  class CommentUpdate < BaseMutation
    argument_record :comment, Comment
    argument :body, String, required: false
    argument :media_uploads, [Mobile::Graph::Types::CommentMediaUploadsInputType], required: false

    returns Mobile::Graph::Types::CommentType

    def perform(comment:, body:, media_uploads: nil)
      form = ::Comments::UpdateForm.new(comment: comment, user: current_user, request_info: request_info)
      form.update body: body, media_uploads: media_uploads
      form
    end
  end
end
