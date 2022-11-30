# frozen_string_literal: true

module Notifications::Helpers::CreateEvent
  extend self

  class InvalidChannelError < StandardError
    def initialize(channel_name)
      super "Invalid channel name - '#{ channel_name }'"
    end
  end

  def call(notification:, channel_name:)
    raise InvalidChannelError, channel_name unless Notifications::Channels.exists? channel_name

    NotificationEvent.create! notification_id: notification.id, channel_name: channel_name
  end
end
