# frozen_string_literal: true

module UpcomingPages
  class SubscriberMessageWorker < ApplicationJob
    include ActiveJobHandleDeserializationError
    include ActiveJobHandleNetworkErrors

    queue_as :upcoming_page_messages

    UNIQUE_ACTIVE_RECORD_ERROR = 'upcoming_page_subscriber_id has already been taken'

    def perform(upcoming_page_message, upcoming_page_subscriber)
      email = upcoming_page_subscriber.email
      token = upcoming_page_subscriber.token

      UpcomingPageMessageDelivery.transaction do
        delivery = UpcomingPageMessageDelivery.create!(
          # TODO(vesln): remove message
          message: upcoming_page_message,
          subject: upcoming_page_message,
          subscriber: upcoming_page_subscriber,
        )

        UpcomingPageMessageMailer.status_update(
          upcoming_page_message: upcoming_page_message,
          to: email,
          token: token,
          custom_id: delivery.id,
          body: UpcomingPages::MessageBodyToHtml.call(upcoming_page_message, subscriber: upcoming_page_subscriber),
        ).deliver_now

        # TODO(Dhruv): Create notification to inform about delivery
        # to the subscriber. e.g "UpcomingPage owner sent a message"
      end
    rescue ActiveRecord::RecordInvalid => e
      raise e unless e.message.include? UNIQUE_ACTIVE_RECORD_ERROR
    rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
      nil
    end
  end
end
