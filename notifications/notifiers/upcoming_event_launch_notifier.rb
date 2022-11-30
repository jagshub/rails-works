# frozen_string_literal: true

module Notifications::Notifiers::UpcomingEventLaunchNotifier
  extend Notifications::Notifiers::BaseNotifier
  extend self

  def channels
    {
      email: {
        priority: :priority,
        user_setting: :send_product_updates_email,
        delay: 10.minutes,
      },
    }
  end

  def user_ids(upcoming_event)
    upcoming_event.followers.ids
  end

  def mailer(notification)
    NotificationMailer.upcoming_event_launched_notification(notification)
  end
end
