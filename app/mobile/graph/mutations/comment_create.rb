# frozen_string_literal: true

module Mobile::Graph::Mutations
  class CommentCreate < BaseMutation
    argument_record :subject, Comment::SUBJECT_TYPES.map(&:safe_constantize), required: true
    argument :body, String, required: false
    argument :poll_options, [Mobile::Graph::Types::PollOptionsInputType], required: false
    argument :media_uploads, [Mobile::Graph::Types::CommentMediaUploadsInputType], required: false

    require_current_user

    returns Mobile::Graph::Types::CommentType

    def perform(inputs)
      form = ::Comments::CreateForm.new(
        user: current_user,
        request_info: request_info,
        source: Mobile::ExtractInfoFromHeaders.get_mobile_source(context[:request]),
      )
      form.update inputs
      form.subject.reload
      form
    end
  end
end
