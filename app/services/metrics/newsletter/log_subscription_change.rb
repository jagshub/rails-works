# frozen_string_literal: true

# This can be triggered by
#  - An unsubscribe link (NotificationEvent)
#  - User Settings page (:user_settings)
#  - User signup (:signup)
#  - Newsletter Banner (:newsletter_banner)
class Metrics::Newsletter::LogSubscriptionChange
  NOTIFICATION_CHANNEL_NAME = 'email'
  NOTIFICATION_KIND = 'newsletter'

  TrackingOptions = Struct.new(:source, :source_details, :notification)

  class << self
    def call(subscriber:, tracking_options: {})
      new(subscriber: subscriber, tracking_options: tracking_options).call
    end
  end

  attr_reader :subscriber, :tracking_options

  def initialize(subscriber:, tracking_options: {})
    @subscriber = subscriber
    @tracking_options = TrackingOptions.new(tracking_options[:source] || 'unknown', tracking_options[:source_details], tracking_options[:notification])
  end

  def call
    return log_unsubscribe! if user_unsubscribed?

    log_subscribe!
  end

  private

  def log_unsubscribe!
    if tracking_options.notification.present?
      # We know the specific email that triggered the unsubscribe
      NotificationUnsubscriptionLog.create_from_notification!(tracking_options.notification, source: tracking_options.source)
    else
      NotificationUnsubscriptionLog.create!(subscriber: subscriber,
                                            channel_name: NOTIFICATION_CHANNEL_NAME,
                                            source: tracking_options.source,
                                            source_details: tracking_options.source_details,
                                            kind: NOTIFICATION_KIND)
    end
  end

  def log_subscribe!
    NotificationSubscriptionLog.create!(
      subscriber: subscriber,
      channel_name: NOTIFICATION_CHANNEL_NAME,
      setting_details: subscriber.newsletter_subscription,
      source: tracking_options.source,
      source_details: tracking_options.source_details,
      kind: NOTIFICATION_KIND,
    )
  end

  def user_unsubscribed?
    subscriber.newsletter_subscription == Newsletter::Subscriptions::UNSUBSCRIBED
  end
end
