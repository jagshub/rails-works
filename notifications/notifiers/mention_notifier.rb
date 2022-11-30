# frozen_string_literal: true

module Notifications::Notifiers::MentionNotifier
  extend Notifications::Notifiers::BaseNotifier
  extend self

  def channels
    {
      browser_push: {
        priority: :mandatory,
        delivery: 'immediate',
        user_setting: :send_mention_browser_push,
      },
      email: {
        priority: :mandatory,
        user_setting: :send_mention_email,
      },
      mobile_push: {
        priority: :mandatory,
        delivery: 'immediate',
        user_setting: :send_mention_push,
      },
    }
  end

  def fan_out?(comment)
    return false if comment.nil?

    # Note(Mike Coutermarsh): If people try to spam mention in a comment (to send notifications). Don't send it.
    return false if user_ids(comment).count > 5

    true
  end

  def send_notification?(notification, _channel)
    fan_out?(notification.notifyable)
  end

  def user_ids(comment)
    Notifications::Helpers::GetMentionedUserIds.for_text(comment.body).delete_if { |id| id == comment.user.id }
  end

  def push_text_heading(notification)
    comment = notification.notifyable
    %(#{ comment.user.name } mentioned you in "#{ comment.subject_name }")
  end

  def push_text_body(notification)
    comment = notification.notifyable
    BetterFormatter.strip_tags(comment.body)
  end

  def push_text_oneliner(notification)
    comment = notification.notifyable
    %(#{ random_emoji } #{ comment.user.name } mentioned you in "#{ comment.subject_name }")
  end

  def thumbnail_url(notification)
    commenter = notification.notifyable.user
    Users::Avatar.url_for_user(commenter, size: 80)
  end

  def mailer(notification)
    NotificationMailer.mention_notification(notification)
  end

  private

  RANDOM_EMOJI = ['💬', '😮', '🙀', '☝️', '👉'].freeze

  def random_emoji
    RANDOM_EMOJI.sample
  end
end
