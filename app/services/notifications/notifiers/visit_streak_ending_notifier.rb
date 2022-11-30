# frozen_string_literal: true

module Notifications::Notifiers::VisitStreakEndingNotifier
  extend Notifications::Notifiers::BaseNotifier
  extend self

  def channels
    {
      mobile_push: {
        priority: :mandatory,
        delivery: 'immediate',
        user_setting: :send_visit_streak_ending_push,
      },
    }
  end

  def user_ids(object)
    [object.user_id]
  end

  def push_text_heading(_notification)
    %(🚨 Don't loose your streak)
  end

  def push_text_body(notification)
    %(Your #{ notification.notifyable.streak_duration } day streak is expiring soon,\n don't loose it now 🔥)
  end

  def push_text_oneliner(notification)
    %(Your #{ notification.notifyable.streak_duration } day streak is expiring soon,\n don't loose it now 🔥)
  end

  def thumbnail_url(notification)
    user = notification.notifyable.user

    Users::Avatar.url_for_user(user, size: 80)
  end

  def weblink_url(_notification)
    "#{ Routes.root_url }streak_pop"
  end
end
