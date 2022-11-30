# frozen_string_literal: true

module UpcomingPages
  class ImportWorker < ApplicationJob
    include ActiveJobHandleDeserializationError
    include ActiveJobHandleMailjetErrors

    queue_as :long_running

    def perform(upcoming_page_email_import)
      UpcomingPages::Importer.call(upcoming_page_email_import)
    end
  end
end
