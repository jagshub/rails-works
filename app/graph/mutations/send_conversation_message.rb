# frozen_string_literal: true

module Graph::Mutations
  class SendConversationMessage < BaseMutation
    argument_record :upcoming_page_conversation, UpcomingPageConversation, required: true, authorize: ApplicationPolicy::MAINTAIN
    argument :body, String, required: true

    returns Graph::Types::UpcomingPageConversationType

    def perform(upcoming_page_conversation:, body:)
      message = upcoming_page_conversation.messages.create!(body: body, user: current_user)

      UpcomingPages::UpcomingPageConversationMessageWorker.perform_later(message)

      upcoming_page_conversation
    end
  end
end
