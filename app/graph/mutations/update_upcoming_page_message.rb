# frozen_string_literal: true

module Graph::Mutations
  class UpdateUpcomingPageMessage < BaseMutation
    argument_record :upcoming_page_message, UpcomingPageMessage, required: true, authorize: ApplicationPolicy::MAINTAIN
    argument :body, Graph::Types::HTMLType, required: false

    returns Graph::Types::UpcomingPageMessageType

    def perform(upcoming_page_message:, body: nil)
      upcoming_page_message.update(body: body)
      upcoming_page_message
    end
  end
end
