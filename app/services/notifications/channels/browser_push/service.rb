# frozen_string_literal: true

module Notifications::Channels::BrowserPush::Service
  extend self

  def call(data)
    External::OneSignalApi.send(data)
  rescue RestClient::RequestTimeout, Net::OpenTimeout, RestClient::Exceptions::OpenTimeout => e
    raise Notifications::Channels::DeliveryError, "Timeout while trying to reach OneSignal: #{ e } data: #{ data }"
  end
end
