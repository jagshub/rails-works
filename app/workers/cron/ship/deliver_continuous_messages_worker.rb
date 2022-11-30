# frozen_string_literal: true

class Cron::Ship::DeliverContinuousMessagesWorker < ApplicationJob
  queue_as :long_running

  def perform
    UpcomingPages::DeliverContinuousMessages.call
  end
end
