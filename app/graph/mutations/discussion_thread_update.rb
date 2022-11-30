# frozen_string_literal: true

module Graph::Mutations
  class DiscussionThreadUpdate < BaseMutation
    argument_record :thread, ::Discussion::Thread, required: true, authorize: :update
    argument_record :category, ::Discussion::Category, required: false
    argument :title, String, required: false
    argument :description, String, required: false

    returns Graph::Types::Discussion::ThreadType

    def perform(thread:, **inputs)
      form = ::Discussion::Form::Thread.new(thread: thread, request_info: request_info)
      form.update(
        title: inputs[:title],
        description: inputs[:description],
        category: inputs[:category],
      )

      form
    end
  end
end
