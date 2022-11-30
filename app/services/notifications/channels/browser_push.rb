# frozen_string_literal: true

module Notifications::Channels::BrowserPush
  extend self

  def channel_name
    :browser_push
  end

  def minimum_hours_distance
    4
  end

  def deliver(notification_event)
    payload = Notifications::Channels::BrowserPush::Payload.from_notification(notification_event)
    Notifications::Channels::BrowserPush::Service.call(payload)
  end

  def delivering_to?(subscriber)
    subscriber.browser_push_token.present?
  end
end
