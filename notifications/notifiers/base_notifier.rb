# frozen_string_literal: true

module Notifications::Notifiers::BaseNotifier
  extend self

  # channels
  #   {
  #     mobile_push/browser_push: {
  #       priority: :optional | :priority,
  #       user_setting: (example) :send_mention_push
  #       minimum_hours_distance: 1 (number) | null (use channel default),
  #       delay: 10.minutes,
  #       delivery: <string> 'immediate' | 'last-active', default set per channel.
  #     },
  #     email: {
  #       priority: :optional | :priority,
  #       user_setting: send_mention_email
  #     },
  #   }
  #
  #   :user_setting is the attribute in `User` or `Mobile::Device` models.
  #   It indicates if user has agreed to received the notification on the channel
  #   When `false`, we don't check for user permissions

  def channels
    raise NotImplementedError, 'Please implement in your notifier'
  end

  # Sane defaults - feel free to overwrite
  def subscriber_ids(object)
    Subscriber.get_ids_by(user_ids: user_ids(object))
  end

  def extract_notifyable(object)
    object
  end

  # Note(andreasklinger): We assume that the majority of notifiers will send to registered
  #   users. Feel free to simply overwrite the user_ids and rely on the default behaviour of
  #   subscriber_ids
  def user_ids(_object)
    []
  end

  def fan_out?(*_args)
    true
  end

  def send_notification?(*_args)
    true
  end

  def fan_out(object, kind:)
    return if object.nil?

    subscriber_ids(object).each do |id|
      Notifications::ScheduleWorker.perform_later kind: kind, object: object, subscriber_id: id
    end
  end

  # Content defaults
  def thumbnail_url(notification)
    Notifications::Helpers::DefaultValues.for(notification.notifyable).thumbnail_url
  end

  def weblink_url(notification)
    Notifications::Helpers::DefaultValues.for(notification.notifyable).weblink_url
  end

  def deeplink_uri(notification)
    Notifications::Helpers::DefaultValues.for(notification.notifyable).deeplink_uri
  end

  def push_text_heading(_notification); end

  def push_text_body(_notification); end

  def push_text_oneliner(_notification); end
end
