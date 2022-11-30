# frozen_string_literal: true

module Graph::Mutations
  class CommentCreate < BaseMutation
    argument_record :subject, Comment::SUBJECT_TYPES.map(&:safe_constantize), required: true
    argument :body, String, required: false
    argument :poll_options, [Graph::Types::Poll::PollOptionsInputType], required: false
    argument :media_uploads, [Graph::Types::CommentMediaUploadsInputType], required: false
    argument :review_id, ID, required: false

    require_current_user

    returns Graph::Types::CommentType

    def perform(inputs)
      form = ::Comments::CreateForm.new(
        user: current_user,
        request_info: request_info,
        source: :web,
      )
      form.update inputs
      form.subject.reload
      form
    end
  end
end
