# frozen_string_literal: true

module Notifications::Notifiers::TopPostCompetitionNotifier
  extend Notifications::Notifiers::BaseNotifier
  extend self

  def channels
    {
      browser_push: {
        priority: :mandatory,
        user_setting: :send_product_recommendation_browser_push,
      },
      mobile_push: {
        priority: :mandatory,
        user_setting: :send_product_recommendation_push,
      },
    }
  end

  def fan_out(object, kind:, user:)
    return if object.nil? || user.nil? || user.subscriber.nil?

    Notifications::ScheduleWorker.perform_later kind: kind, object: object, subscriber_id: user.subscriber.id
  end

  def push_text_heading(notification)
    post = notification.notifyable
    pick_title_for(post)
  end

  def push_text_body(_notification)
    "Check out one of today's trending products."
  end

  def push_text_oneliner(_notification)
    "Check out today's top products!"
  end

  private

  def pick_title_for(post)
    badges = post.badges
    is_top = badges.present? ? badges.first.data['position'] == 1 : false

    msg_text = is_top ? '%s is #1 for today, but can it keep the prized spot?' : '%s is close to becoming the #1 product of the day!'
    format(msg_text, post.name)
  end
end
