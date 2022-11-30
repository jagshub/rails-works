# frozen_string_literal: true

module Notifications::PushMetricsSync
  extend self

  def call(sync_last_hours: NotificationPushLog::HOURLY_SYNC_WINDOW, api_type: NotificationPushLog::DEFAULT_API_TYPE)
    offset = 0
    get_next_page = true

    while get_next_page
      notifications = External::OneSignalApi.fetch_notifications(offset: offset, kind: api_type)
      break if notifications.nil?

      get_next_page = false if notifications.empty? || exceeds_time_window?(notifications.last, sync_last_hours)

      notifications.each do |notification|
        data = to_model_attributes(notification)
        push_notification = NotificationPushLog.find_or_initialize_by(uuid: data[:uuid])
        push_notification.update!(data)
      end

      offset += 50
    end
  end

  private

  def exceeds_time_window?(notification, sync_last_hours)
    last_notification_timestamp = DateTime.strptime(notification['queued_at'].to_s, '%s').to_i
    diff_in_hours = ((DateTime.now.to_i - last_notification_timestamp) / 3600.00).round(2)

    Rails.logger.info "Last Notification in page was #{ diff_in_hours }hrs ago."
    diff_in_hours >= sync_last_hours
  end

  def to_model_attributes(notification)
    meta = notification['data']
    subscriber = Subscriber.find_by_id(meta['subscriber_id'])
    data = {
      channel: meta['channel'] || 'unknown_channel',
      kind: meta['kind'] || 'unknown_kind',
      user_id: meta['subscriber_id'] ? subscriber&.user_id : nil,
      notification_event_id: meta['notification_event_id'] || nil,
    }.stringify_keys!

    platform = notification['platform_delivery_stats']
    platform = platform.empty? ? 'unknown_platform' : platform.keys.first

    {
      uuid: notification['id'],
      channel: data['channel'],
      kind: data['kind'],
      received: notification['received'],
      converted: notification['converted'],
      url: notification['url'],
      platform: platform,
      delivery_method: notification['delayed_option'] || 'immediate',
      sent_at: DateTime.strptime(notification['queued_at'].to_s, '%s'),
      raw_response: notification.to_json,
      user_id: data['user_id'],
      notification_event_id: data['notification_event_id'],
    }
  end
end
