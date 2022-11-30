# frozen_string_literal: true

module ActiveJobHandleTwitterErrors
  include ActiveJobRetriesCount

  extend ActiveSupport::Concern

  ERRORS = [
    Twitter::Error::InternalServerError,
    Twitter::Error::ServiceUnavailable,
    Twitter::Error::BadRequest,
    Twitter::Error::Unauthorized,
  ].freeze

  included do
    rescue_from(*ERRORS) do |exception|
      if retries_count <= 10
        retry_job wait: 5.minutes
      else
        ErrorReporting.report_warning(exception)
      end
    end
  end
end
