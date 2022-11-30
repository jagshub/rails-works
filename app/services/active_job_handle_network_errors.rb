# frozen_string_literal: true

module ActiveJobHandleNetworkErrors
  include ActiveJobRetriesCount

  extend ActiveSupport::Concern

  HTTP_ERRORS = [
    Addressable::URI::InvalidURIError,
    EOFError,
    Errno::ECONNREFUSED,
    Errno::ECONNRESET,
    Errno::EINVAL,
    Errno::EMFILE,
    Errno::ENETUNREACH,
    Errno::EPIPE,
    Errno::ETIMEDOUT,
    Errno::EFAULT,
    Faraday::ConnectionFailed,
    Faraday::TimeoutError,
    HTTP::ConnectionError,
    HTTParty::Error,
    IOError,
    JSON::ParserError,
    Net::HTTPBadResponse,
    Net::HTTPHeaderSyntaxError,
    Net::OpenTimeout,
    Net::ProtocolError,
    Net::ReadTimeout,
    OpenSSL::SSL::SSLError,
    OpenURI::HTTPError,
    RestClient::BadGateway,
    RestClient::BadRequest,
    RestClient::Conflict,
    RestClient::Exceptions::OpenTimeout,
    RestClient::Exceptions::ReadTimeout,
    RestClient::Forbidden,
    RestClient::GatewayTimeout,
    RestClient::InternalServerError,
    RestClient::NotFound,
    RestClient::RequestFailed,
    RestClient::ServerBrokeConnection,
    RestClient::ServiceUnavailable,
    Timeout::Error,
    SocketError,
  ].freeze

  included do
    rescue_from(*HTTP_ERRORS) do |exception|
      if retries_count <= 20
        retry_job wait: 5.minutes
      else
        ErrorReporting.report_error(exception)
      end
    end
  end
end
