# frozen_string_literal: true

module API::V2Internal::Mutations
  class CommentCreate < BaseMutation
    argument :body, String, required: false

    node :post, type: ::Post

    authorize :create do |node|
      Comment.new(subject: node)
    end

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

    private

    def params
      inputs.slice(:body).merge(subject: node)
    end
  end
end
