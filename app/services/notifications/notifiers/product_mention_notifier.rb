# frozen_string_literal: true

module Notifications::Notifiers::ProductMentionNotifier
  extend Notifications::Notifiers::BaseNotifier
  extend self

  def channels
    {
      browser_push: {
        priority: :mandatory,
        user_setting: :send_mention_browser_push,
        delivery: 'immediate',
      },
      mobile_push: {
        priority: :mandatory,
        user_setting: :send_mention_push,
        delivery: 'immediate',
      },
    }
  end

  def fan_out?(comment)
    return false if comment.nil?

    # Note(TC): We only want to run this notifier for discussion comments
    return false unless discussion_comment?(comment)

    makers_for_products_mentioned = user_ids(comment)
    return false if makers_for_products_mentioned.empty?

    true
  end

  def send_notification?(notification, _channel)
    fan_out?(notification.notifyable)
  end

  def user_ids(comment)
    makers_user_ids = Notifications::Helpers::GetMentionedMakerUserIds.for_text(comment.body)

    # Note(TC): We dont want to send notifications to other makers when a person from the posts makers group
    # is trying to do some form of self promotion on a comment.
    makers_user_ids.include?(comment.user.id) ? [] : makers_user_ids
  end

  def push_text_heading(notification)
    comment = notification.notifyable
    %(💬 #{ comment.user.name } mentioned a product you made in "#{ comment.subject_name }")
  end

  def push_text_body(notification)
    comment = notification.notifyable
    BetterFormatter.strip_tags(comment.body.truncate(250))
  end

  def push_text_oneliner(notification)
    comment = notification.notifyable
    BetterFormatter.strip_tags(comment.body.truncate(250))
  end

  def thumbnail_url(notification)
    commenter = notification.notifyable.user
    Users::Avatar.url_for_user(commenter, size: 80)
  end

  private

  def discussion_comment?(comment)
    comment.subject.is_a? Discussion::Thread
  end
end
