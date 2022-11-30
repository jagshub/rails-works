# frozen_string_literal: true

module Graph::Mutations
  class CommentUpdate < BaseMutation
    argument_record :comment, Comment
    argument :body, String, required: false
    argument :media_uploads, [Graph::Types::CommentMediaUploadsInputType], required: false

    returns Graph::Types::CommentType

    def perform(comment:, body:, media_uploads:)
      form = ::Comments::UpdateForm.new(comment: comment, user: current_user, request_info: request_info)
      form.update body: body, media_uploads: media_uploads
      form
    end
  end
end
