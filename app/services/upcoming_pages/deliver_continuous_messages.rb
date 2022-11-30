# frozen_string_literal: true

module UpcomingPages
  module DeliverContinuousMessages
    extend self

    def call
      UpcomingPageMessage.continuous.sent.find_each do |message|
        UpcomingPages::EnqueueMessageWorker.perform_later(message)
      end
    end
  end
end
