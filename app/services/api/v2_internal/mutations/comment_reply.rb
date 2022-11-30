# frozen_string_literal: true

module API::V2Internal::Mutations
  class CommentReply < BaseMutation
    argument :body, String, required: false
    argument :parent_id, ID, required: true, camelize: false

    node :post, type: Post

    returns API::V2Internal::Types::CommentType

    def perform
      form = ::Comments::CreateForm.new(
        user: current_user,
        request_info: request_info,
        source: :mobile,
      )
      form.update params
      form
    end

    def params
      { body: inputs[:body], subject: node, parent_comment_id: inputs[:parent_id] }
    end
  end
end
