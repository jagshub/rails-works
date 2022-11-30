# frozen_string_literal: true

class Notifications::Helpers::DefaultChecks
  class << self
    def check(event)
      new(event).check
    end
  end

  def initialize(event)
    @event = event
    @notifier = event.notifier
    @channel = event.channel
  end

  def check
    return :already_sent if notification_already_sent?
    return :dont_sent unless notifier_allows?
    return :dont_sent unless channel_accepted?
    return :dont_sent unless user_accepts_notification?
    return :postpone if too_many_optional_notifications?

    :send
  end

  private

  attr_reader :event, :channel, :notifier

  def notifier_allows?
    notifier.send_notification? event, channel: channel.channel_name
  end

  def notification_already_sent?
    !(event.pending? || event.postponed?)
  end

  def too_many_optional_notifications?
    priority = settings.fetch(:priority) { raise "Missing :priority in #{ notifier.name }.channels[:#{ channel.channel_name }]" }
    priority == :optional && event.too_many_notifications?
  end

  def channel_accepted?
    channel.delivering_to? event.subscriber
  end

  def settings
    @settings ||= notifier.channels[channel.channel_name]
  end

  def user_accepts_notification?
    return true if event.user.blank?

    channel_name = channel.channel_name

    # NOTE(rstankov): Ignore checks for mobile push, for now.
    #   Those checks are done in notifier
    return true if channel_name == :mobile_push

    user_setting = settings.fetch(:user_setting) { raise "Missing :user_setting in #{ notifier.name }.channels[:#{ channel_name }]" }

    return true unless user_setting

    Notifications::UserPreferences.accepted?(event.user, user_setting)
  end
end
