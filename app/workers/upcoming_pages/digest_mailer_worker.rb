# frozen_string_literal: true

module UpcomingPages
  class DigestMailerWorker < ApplicationJob
    include ActiveJobHandleDeserializationError
    include ActiveJobHandleNetworkErrors

    queue_as :upcoming_page_messages

    def perform(upcoming_page, start_time_s, end_time_s)
      start_time = Time.zone.parse(start_time_s)
      end_time = Time.zone.parse(end_time_s)

      UpcomingPageMailer.digest(upcoming_page, start_time, end_time).deliver_now
    end
  end
end
