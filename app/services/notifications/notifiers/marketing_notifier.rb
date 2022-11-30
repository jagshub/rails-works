# frozen_string_literal: true

module Notifications::Notifiers::MarketingNotifier
  extend Notifications::Notifiers::BaseNotifier
  extend self

  def channels
    {
      mobile_push: {
        priority: :optional,
        minimum_hours_distance: 24,
        user_setting: :send_community_updates_push,
      },
    }
  end

  def user_ids(object)
    object.user_ids.split(',').reject(&:blank?).map(&:to_i)
  end

  def push_text_heading(notification)
    notification.notifyable.heading
  end

  def push_text_body(notification)
    notification.notifyable.body
  end

  def push_text_oneliner(notification)
    notification.notifyable.one_liner
  end

  def weblink_url(notification)
    notification.notifyable.deeplink
  end
end
