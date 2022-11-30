# frozen_string_literal: true

module Jobs
  class DigestWorker < ApplicationJob
    include ActiveJobHandleMailjetErrors
    include ActiveJobHandleDeserializationError
    include ActiveJobRetriesCount

    queue_as :notifications

    rescue_from OpenSSL::SSL::SSLError do |exception|
      if retries_count <= 10
        retry_job wait: 5.minutes
      else
        ErrorReporting.report_error(exception)
      end
    end

    def perform(subscriber)
      return if subscriber.email.blank?

      presenter = Jobs::DigestPresenter.new(subscriber)
      JobsMailer.digest(presenter).deliver_now
    end
  end
end
