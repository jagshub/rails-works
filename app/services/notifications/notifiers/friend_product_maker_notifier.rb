# frozen_string_literal: true

module Notifications::Notifiers::FriendProductMakerNotifier
  extend Notifications::Notifiers::BaseNotifier
  extend self

  def channels
    {
      browser_push: {
        priority: :optional,
        user_setting: :send_friend_post_browser_push,
        delivery: 'immediate',
      },
      mobile_push: {
        priority: :optional,
        user_setting: :send_friend_post_push,
        delivery: 'immediate',
      },
      email: {
        delay: 30.minutes,
        user_setting: :send_friend_post_email,
        priority: :optional,
      },
    }
  end

  def fan_out?(product_maker)
    # Note(andreasklinger): We only want to send friend product maker notifications once
    return false if NotificationLog.where(kind: NotificationLog.kinds.fetch(:friend_product_maker), notifyable: product_maker).exists?

    # NOTE(rstankov): We already notify all of hunter's friends about this post
    return false if product_maker.post.user_id == product_maker.user_id

    # Note(andreasklinger): To avoid spammers we only want to send notifications for featured posts
    return false if product_maker.post.blank?
    return false if product_maker.post.trashed?
    return false unless product_maker.post.featured?

    # Note(andreasklinger): We do not want to send a notification about something that's old
    return false unless product_maker.post.scheduled_at > 3.days.ago

    true
  end

  def send_notification?(notification_event, _channel)
    return false if notification_event.notifyable.blank?
    return false if notification_event.notifyable.post.blank?
    return false unless notification_event.notifyable.post.featured?

    return false if maker_notification_already_sent_for_post?(notification_event)

    true
  end

  def user_ids(product_maker)
    product_maker.user.follower_ids
  end

  def push_text_heading(notification)
    post = notification.notifyable.post
    maker = notification.notifyable

    %(#{ maker.user.name } just launched "#{ post.name }")
  end

  def push_text_oneliner(notification)
    push_text_heading(notification)
  end

  def push_text_body(notification)
    notification.notifyable.post.tagline
  end

  def mailer(notification)
    NotificationMailer.friend_product_maker_notification(notification)
  end

  def thumbnail_url(notification)
    Notifications::Helpers::DefaultValues.for(notification.notifyable.post).thumbnail_url
  end

  def weblink_url(notification)
    Notifications::Helpers::DefaultValues.for(notification.notifyable.post).weblink_url
  end

  def deeplink_uri(notification)
    Notifications::Helpers::DefaultValues.for(notification.notifyable.post).deeplink_uri
  end

  private

  # Note(Mike Coutermarsh): For posts with multiple makers, do not send people
  #   more than 1 notification per post.
  def maker_notification_already_sent_for_post?(notification_event)
    post = notification_event.notifyable.post

    other_makers = post.product_makers.where('id != ?', notification_event.notifyable.id).pluck(:id)
    return unless other_makers.any?

    maker_notifications = NotificationLog.where(notifyable: other_makers,
                                                subscriber: notification_event.subscriber,
                                                kind: NotificationLog.kinds[notification_event.kind]).pluck(:id)

    maker_notifications.any? && NotificationEvent.where(notification: maker_notifications).sent.exists?
  end
end
