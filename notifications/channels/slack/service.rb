# frozen_string_literal: true

class Notifications::Channels::Slack::Service
  class << self
    def call(url:, message:)
      notifier = Slack::Notifier.new url
      notifier.ping message
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, Net::OpenTimeout => e
      raise Notifications::Channels::DeliveryError, "Error for #{ url }. Exception: #{ e.message }"
    end
  end
end
