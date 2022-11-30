# frozen_string_literal: true

module Mobile::Graph::Mutations
  class CommentReply < BaseMutation
    argument_record :subject, [Post, Discussion::Thread, Anthologies::Story]
    argument :body, String, required: false
    argument :media_uploads, [Mobile::Graph::Types::CommentMediaUploadsInputType], required: false
    argument_record :parent_comment, Comment

    returns Mobile::Graph::Types::CommentType

    require_current_user

    def perform(inputs)
      form = ::Comments::CreateForm.new(
        user: current_user,
        request_info: request_info,
        source: Mobile::ExtractInfoFromHeaders.get_mobile_source(context[:request]),
      )
      form.update params(inputs)
      form
    end

    def params(inputs)
      {
        body: inputs[:body],
        media_uploads: inputs[:media_uploads],
        subject: inputs[:subject],
        parent_comment_id: inputs[:parent_comment].id,
      }
    end
  end
end
