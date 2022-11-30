# frozen_string_literal: true

module Graph::Mutations
  class MarkMessageResponsesAsSeen < BaseMutation
    argument_record :upcoming_page_message, UpcomingPageMessage, required: true, authorize: ApplicationPolicy::MAINTAIN

    returns Graph::Types::UpcomingPageMessageType

    def perform(upcoming_page_message:)
      upcoming_page_message.conversations.not_trashed.unseen.update_all seen_at: Time.current
      upcoming_page_message
    end
  end
end
