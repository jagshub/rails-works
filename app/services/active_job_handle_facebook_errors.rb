# frozen_string_literal: true

module ActiveJobHandleFacebookErrors
  include ActiveJobRetriesCount

  extend ActiveSupport::Concern

  ERRORS = [
    Koala::Facebook::AuthenticationError,
    Koala::Facebook::ServerError,
    Koala::Facebook::ClientError,
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
