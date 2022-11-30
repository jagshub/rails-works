# frozen_string_literal: true

module Notifications::Channels::MobilePush
  extend self

  def channel_name
    :mobile_push
  end

  def minimum_hours_distance
    1
  end

  def deliver(notification_event)
    mobile_devices = Mobile::Device.enabled_push_for(user_id: notification_event.subscriber&.user_id, option: "send_#{ notification_event.kind }_push")

    tokens = mobile_devices.map(&:one_signal_player_id) if mobile_devices.present?

    # NOTE(Bharat): This is temporary. Used as a fallback option.
    tokens = [notification_event.subscriber.mobile_push_token] if tokens.blank? && notification_event.subscriber.mobile_push_token.present?

    return if tokens.blank?

    payload = Notifications::Channels::MobilePush::Payload.call(notification: notification_event, tokens: tokens)
    Notifications::Channels::MobilePush::Service.call(payload)
  end

  def delivering_to?(subscriber)
    Mobile::Device.enabled_push_for(user_id: subscriber&.user_id).exists? || subscriber.mobile_push_token.present?
  end
end
