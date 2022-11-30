# frozen_string_literal: true

module UpcomingPages
  class EnrichmentWorker < ApplicationJob
    include ActiveJobRetriesCount
    include ActiveJobHandleDeserializationError
    include ActiveJobHandlePostgresErrors

    rescue_from Nestful::ServerError, Nestful::ClientError do
      retry_job wait: 1.minute if retries_count <= 5
    end

    queue_as :upcoming_page_messages

    def perform(subscriber)
      UpcomingPages::Enrichment.call(subscriber.email)
    end
  end
end
