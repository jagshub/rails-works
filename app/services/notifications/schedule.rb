# frozen_string_literal: true

module Notifications::Schedule
  extend self

  def call(kind:, object:, subscriber_id:)
    channels = channels_to_deliver(kind, subscriber_id)

    return if channels.empty?

    notification = Notifications::Helpers::CreateNotification.call(kind: kind, object: object, subscriber_id: subscriber_id)

    return if notification.nil?

    channels.each do |(channel_name, options)|
      create_event notification, channel_name, options
    end

    notification
  end

  private

  def create_event(notification, channel_name, options)
    event = Notifications::Helpers::CreateEvent.call(notification: notification, channel_name: channel_name)
    Notifications::DeliveryWorker.set(wait: options.fetch(:delay, 0)).perform_later(event: event)
  end

  def channels_to_deliver(kind, subscriber_id)
    subscriber = Subscriber.find subscriber_id
    notifier = Notifications::Notifiers.for(kind)
    notifier.channels.select { |(channel_name, _options)| Notifications::Channels[channel_name].delivering_to?(subscriber) }.to_h
  end
end
