# frozen_string_literal: true

module Mobile::Graph::Mutations
  class DiscussionThreadCreate < BaseMutation
    argument_record :category, ::Discussion::Category, required: false
    argument :title, String, required: false
    argument :description, String, required: false
    argument :beta, String, required: false

    returns Mobile::Graph::Types::Discussion::ThreadType

    authorize :create, ::Discussion::Thread

    def perform(inputs)
      form = ::Discussion::Form::Thread.new(
        request_info: request_info,
        source: Mobile::ExtractInfoFromHeaders.get_mobile_source(context[:request]),
      )

      form.update(
        title: inputs[:title],
        description: inputs[:description],
        subject: get_subject(inputs[:beta]),
        user_id: current_user.id,
        category: inputs[:category],
        status: 'pending',
      )

      form
    end

    def get_subject(beta)
      MakerGroups.find_group(beta, current_user)
    end
  end
end
