# frozen_string_literal: true

module Notifications::Channels::Slack
  extend self

  def channel_name
    :slack
  end

  def minimum_hours_distance
    5
  end

  def deliver(notification_event)
    payload = Notifications::Channels::Slack::Payload.from_notification(notification_event)
    response = Notifications::Channels::Slack::Service.call(payload)

    handle_delivery_response response.body, notification_event if response.present?
  end

  def delivering_to?(subscriber)
    subscriber.slack_active && subscriber.slack_webhook_url.present?
  end

  private

  SLACK_WAS_REMOVED_ERRORS = [
    'user_not_found',
    'action_prohibited',
    'channel_not_found',
    'channel_is_archived',
    'No service',
  ].freeze

  # NOTE(rstankov): Disable this subscriber's slack channel, because webhook url is no longer valid
  # This handles cases when user has removed slack bot from slack channel.
  #
  # Documentation:
  #
  # https://api.slack.com/incoming-webhooks
  # https://api.slack.com/changelog/2016-05-17-changes-to-errors-for-incoming-webhooks
  def handle_delivery_response(body, notification)
    notification.subscriber.update! slack_active: false if SLACK_WAS_REMOVED_ERRORS.include? body
  end
end
