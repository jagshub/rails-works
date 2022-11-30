# frozen_string_literal: true

module Graph::Mutations
  class DestroyUpcomingPageConversation < BaseMutation
    argument_record :upcoming_page_conversation, UpcomingPageConversation, required: true, authorize: :destroy

    returns Graph::Types::UpcomingPageConversationType

    def perform(upcoming_page_conversation:)
      upcoming_page_conversation.trash
      upcoming_page_conversation
    end
  end
end
