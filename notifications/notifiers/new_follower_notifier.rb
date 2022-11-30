# frozen_string_literal: true

module Notifications::Notifiers::NewFollowerNotifier
  extend Notifications::Notifiers::BaseNotifier
  extend self

  def channels
    {
      email: {
        delay: 2.hours,
        priority: :optional,
        minimum_hours_distance: 24,
        user_setting: :send_new_follower_email,
      },
      browser_push: {
        delay: 2.hours,
        priority: :optional,
        user_setting: :send_new_follower_browser_push,
      },
      mobile_push: {
        delay: 1.hour,
        priority: :optional,
        delivery: 'immediate',
        user_setting: :send_new_follower_push,
      },
    }
  end

  def user_ids(user_friend_association)
    [user_friend_association.following_user_id]
  end

  def fan_out?(user_friend_association)
    followed_by_user = user_friend_association.followed_by_user
    following_user = user_friend_association.following_user

    return false unless Spam::User.credible_role? followed_by_user
    return true if followed_by_user.follower_count >= user_friend_association.following_user.follower_count
    return true if following_user.follows? followed_by_user
    return true if TwitterVerifiedUser.verified? followed_by_user

    false
  end

  def extract_notifyable(user_friend_association)
    user_friend_association.followed_by_user
  end

  def push_text_heading(_notification)
    'New follower 🤗'
  end

  def push_text_body(notification)
    pick_title_for notification
  end

  def push_text_oneliner(notification)
    pick_title_for notification
  end

  def mailer(notification)
    subject = pick_title_for notification
    NotificationMailer.new_follower_notification(notification, subject: subject)
  end

  private

  TITLES = [
    'Hooray! %s just followed you 🎉',
    'Yay! New friend. %s just followed you 👍',
    'Yippy! %s just followed you 💯',
    'Sweet! %s just followed you 🙌',
    'Radical! %s just followed you 😎',
  ].freeze

  def pick_title_for(notification)
    format(TITLES.sample, notification.notifyable.name)
  end
end
