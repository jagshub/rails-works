# frozen_string_literal: true

module Graph::Mutations
  class DestroyUpcomingPageMessage < BaseMutation
    argument_record :upcoming_page_message, UpcomingPageMessage, required: true, authorize: :destroy

    returns Graph::Types::UpcomingPageMessageType

    def perform(upcoming_page_message:)
      upcoming_page_message.destroy!

      success upcoming_page_message
    end
  end
end
