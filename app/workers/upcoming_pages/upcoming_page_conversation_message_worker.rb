# frozen_string_literal: true

module UpcomingPages
  class UpcomingPageConversationMessageWorker < ApplicationJob
    include ActiveJobHandleDeserializationError
    include ActiveJobHandleNetworkErrors

    queue_as :upcoming_page_messages

    UNIQUE_ACTIVE_RECORD_ERROR = 'upcoming_page_subscriber_id has already been taken'

    def perform(upcoming_page_conversation_messsage)
      UpcomingPageMessageDelivery.transaction do
        subscriber = upcoming_page_conversation_messsage.conversation.subscriber

        delivery = UpcomingPageMessageDelivery.create!(
          subject: upcoming_page_conversation_messsage,
          subscriber: subscriber,
        )

        UpcomingPageMessageMailer.conversation(delivery).deliver_now
      end
    rescue ActiveRecord::RecordInvalid => e
      raise e unless e.message.include? UNIQUE_ACTIVE_RECORD_ERROR
    end
  end
end
