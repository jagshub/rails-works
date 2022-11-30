# frozen_string_literal: true

module Notifications::Notifiers::TopMakerNotifier
  extend Notifications::Notifiers::BaseNotifier
  extend self

  def channels
    {
      email: {
        priority: :optional,
        user_setting: :send_friend_post_email,
      },
    }
  end

  def user_ids(post)
    [post.makers.first.id]
  end

  def fan_out?(post)
    post.featured?
  end

  def mailer(notification)
    Notifications::Channels::Email::TopMakerNotification.new(notification)
  end
end
