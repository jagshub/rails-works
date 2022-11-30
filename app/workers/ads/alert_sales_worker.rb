# frozen_string_literal: true

class Ads::AlertSalesWorker < ApplicationJob
  include ActiveJobHandleDeserializationError

  def perform
    return if already_notified_today? || Ads::FindAd.active_ads.present?

    alert_msg = <<~MSG
      #{ Time.current.hour }:00 hrs
      * No ads to show for this hour.
      * Possible, active budgets reached daily cap.
    MSG

    save_last_alert_time
    SlackNotify.call(
      text: alert_msg,
      username: 'Active Ad monitor ',
      icon_emoji: 'moneybag',
      channel: :sales_operations,
    )
  end

  private

  def already_notified_today?
    fetch_last_alert_time == Time.zone.today.to_s
  end

  def fetch_last_alert_time
    RedisConnect.current.get('no_active_ads_alert_at')
  end

  def save_last_alert_time
    RedisConnect.current.set('no_active_ads_alert_at', Time.zone.today.to_s)
  end
end
