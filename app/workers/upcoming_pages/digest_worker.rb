# frozen_string_literal: true

module UpcomingPages
  class DigestWorker < ApplicationJob
    include ActiveJobHandleMailjetErrors

    queue_as :upcoming_page_messages

    def perform
      UpcomingPages::Digest.call(1.week.ago, Time.zone.now)
    end
  end
end
