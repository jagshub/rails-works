# frozen_string_literal: true

module Notifications::Notifiers::AwardedBadgesNotifier
  extend Notifications::Notifiers::BaseNotifier
  extend self

  def channels
    {
      email: {
        priority: :optional,
        user_setting: :send_awarded_badges_email,
      },
    }
  end

  def user_ids(badge)
    post = badge.subject
    post.maker_ids
  end

  def mailer(notification)
    case notification.notifyable.data['period'].to_sym
    when :daily
      NotificationMailer.awarded_badges_notification_daily(notification)
    when :weekly
      NotificationMailer.awarded_badges_notification_weekly(notification)
    when :monthly
      NotificationMailer.awarded_badges_notification_monthly(notification)
    else
      raise "Unknown period for awarded badge mailing data - #{ period } in Notifier"
    end
  end
end
