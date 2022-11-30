# frozen_string_literal: true

module Notifications::Channels::MobilePush::Service
  extend self

  def call(data)
    External::OneSignalApi.send(data)
  rescue RestClient::RequestTimeout, Net::OpenTimeout, RestClient::Exceptions::OpenTimeout, RestClient::Exceptions::ReadTimeout, Net::ReadTimeout => e
    raise Notifications::Channels::DeliveryError, "Timeout while trying to reach OneSignal: #{ e } data: #{ data }"
  end
end
