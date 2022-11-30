# frozen_string_literal: true

module Notifications::Notifiers::ShoutoutMentionNotifier
  extend Notifications::Notifiers::BaseNotifier
  extend self

  def channels
    {
      email: {
        priority: :mandatory,
        user_setting: :shoutout_mention,
      },
    }
  end

  def user_ids(object)
    object.mentions.where.not(user_id: object.user_id).pluck(:user_id)
  end

  def mailer(notification)
    NotificationMailer.shoutout_mention_notification(notification)
  end
end
