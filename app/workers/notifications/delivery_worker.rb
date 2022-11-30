# frozen_string_literal: true

class Notifications::DeliveryWorker < ApplicationJob
  include ActiveJobRetriesCount
  include ActiveJobHandleMailjetErrors
  include ActiveJobHandleNetworkErrors
  include ActiveJobHandleDeserializationError

  queue_as :notifications

  rescue_from Notifications::Channels::DeliveryError do |exception|
    if retries_count <= 30
      retry_job wait: 5.minutes
    else
      ErrorReporting.report_error(exception)
    end
  end

  def perform(event:)
    Notifications::Deliver.call(event)
  end
end
