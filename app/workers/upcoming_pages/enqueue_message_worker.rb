# frozen_string_literal: true

module UpcomingPages
  class EnqueueMessageWorker < ApplicationJob
    include ActiveJobHandleDeserializationError
    queue_as :long_running

    def perform(upcoming_page_message)
      subscribers = upcoming_page_message.to

      subscribers.find_each do |subscriber|
        next if upcoming_page_message.deliveries.where(upcoming_page_subscriber_id: subscriber.id).exists?

        UpcomingPages::SubscriberMessageWorker.perform_later(upcoming_page_message, subscriber)
      end

      upcoming_page_message.update!(sent_to_count: subscribers.count)
    end
  end
end
