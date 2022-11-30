# frozen_string_literal: true

module UpcomingPages
  class WebhookWorker < ApplicationJob
    include ActiveJobHandleDeserializationError
    include ActiveJobHandleNetworkErrors

    queue_as :upcoming_page_messages

    def perform(subscriber, event)
      return if subscriber.upcoming_page.webhook_url.blank?

      UpcomingPages::Webhook.call(subscriber, event)
    end
  end
end
