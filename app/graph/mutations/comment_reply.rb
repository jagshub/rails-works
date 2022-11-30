# frozen_string_literal: true

module Graph::Mutations
  class CommentReply < BaseMutation
    argument_record :subject, [Post, Recommendation, Review, UpcomingPageMessage, Discussion::Thread, Anthologies::Story, ProductRequest]
    argument :body, String, required: false
    argument :media_uploads, [Graph::Types::CommentMediaUploadsInputType], required: false
    argument_record :parent_comment, Comment

    returns Graph::Types::CommentType

    require_current_user

    def perform(inputs)
      form = ::Comments::CreateForm.new(
        user: current_user,
        request_info: request_info,
        source: :web,
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
