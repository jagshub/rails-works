# frozen_string_literal: true

module Notifications::Notifiers::MakerAcceptedGroupMemberNotifier
  extend Notifications::Notifiers::BaseNotifier
  extend self

  def channels
    {
      browser_push: {
        priority: :optional,
        user_setting: :maker_group_member,
      },
    }
  end

  def user_ids(member)
    [member.user_id]
  end

  def send_notification?(notification_event, _channel)
    return false if notification_event.notifyable.blank?
    return false unless notification_event.notifyable.assessed?

    notification_event.subscriber.user != notification_event.notifyable.user
  end

  def push_text_heading(_notification_event)
    'Makers'
  end

  def push_text_body(notification_event)
    member = notification_event.notifyable
    %(Yay! You’re now a member of #{ member.group.name })
  end
end
