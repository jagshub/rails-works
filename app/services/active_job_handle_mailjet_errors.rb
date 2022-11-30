# frozen_string_literal: true

module ActiveJobHandleMailjetErrors
  include ActiveJobRetriesCount

  extend ActiveSupport::Concern

  ERRORS = [
    Errno::ECONNRESET,
    Errno::ECONNREFUSED,
    Errno::EPIPE,
    JSON::ParserError,
    Mailjet::ApiError,
    Net::ReadTimeout,
    OpenSSL::SSL::SSLError,
    RestClient::BadRequest,
    RestClient::Exceptions::ReadTimeout,
    SocketError,
  ].freeze

  included do
    rescue_from(*ERRORS) do |exception|
      if retries_count <= 50
        retry_job wait: 5.minutes
      else
        ErrorReporting.report_error(exception)
      end
    end
  end
end
