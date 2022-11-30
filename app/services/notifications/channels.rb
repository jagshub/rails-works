# frozen_string_literal: true

module Notifications::Channels
  extend self

  CHANNELS = [
    Notifications::Channels::Email,
    Notifications::Channels::MobilePush,
    Notifications::Channels::BrowserPush,
    Notifications::Channels::Slack,
  ].map { |channel| [channel.channel_name, channel] }.to_h

  def [](name)
    CHANNELS.fetch name.to_sym
  end

  def exists?(name)
    CHANNELS.key? name.to_sym
  end
end
