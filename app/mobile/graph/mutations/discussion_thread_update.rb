# frozen_string_literal: true

module Mobile::Graph::Mutations
  class DiscussionThreadUpdate < BaseMutation
    argument_record :thread, ::Discussion::Thread, required: true, authorize: :update
    argument_record :category, ::Discussion::Category, required: false
    argument :title, String, required: false
    argument :description, String, required: false

    returns Mobile::Graph::Types::Discussion::ThreadType

    def perform(thread:, **inputs)
      form = ::Discussion::Form::Thread.new(
        thread: thread,
        request_info: request_info,
        source: Mobile::ExtractInfoFromHeaders.get_mobile_source(context[:request]),
      )
      form.update(
        title: inputs[:title],
        description: inputs[:description],
        category: inputs[:category],
      )

      form
    end
  end
end
