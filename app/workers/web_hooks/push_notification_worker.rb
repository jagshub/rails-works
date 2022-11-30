# frozen_string_literal: true

# NOTE(ayrton) Jobs are created from our webhooks app using the Sidekiq
# message format.
#
# The Sidekiq message format is different than the ActiveJob message format,
# and is way less complex. Make sure to include `Sidekiq::Worker` and not
# class `ActiveJob::Base`.
#
# In case we want to switch to the AJ message format we can look how Sidekiq
# does this internally: https://github.com/rails/rails/blob/master/activejob/lib/active_job/arguments.rb
#
# If you change the class make sure to change it in the webhooks app as well:
# https://github.com/producthunt/webhooks/blob/master/lib/constants.js
#
# Documentation: https://documentation.onesignal.com/docs/webhooks

class WebHooks::PushNotificationWorker
  include Sidekiq::Worker

  PROVIDER = 'one_signal'

  EVENTS = [
    'notification.clicked',
    'notification.dismissed',
    'notification.displayed',
  ].freeze

  def perform(payload = {})
    return unless payload['provider'] == PROVIDER
    return unless EVENTS.include? payload['event']

    subscriber = notification_subscriber(payload)
    return if subscriber.blank?

    External::SegmentApi.track(event: 'push_notification', properties: event_properties(payload), **user_or_anonymous_id(subscriber))
    External::SegmentApi.flush
  end

  private

  def event_properties(payload)
    metadata = payload.fetch('data', {})
    kind = metadata['kind'] || (metadata['__isOneSignalWelcomeNotification'] ? 'welcome' : nil) || 'manual'

    {
      channel: metadata['channel'],
      kind: kind,
      action: payload['event'].split('.').last,
      subscriber_id: metadata['subscriber_id'],
      notification_event_id: metadata['notification_event_id'],
      one_signal_id: payload['id'],
      one_signal_user_token: payload['userId'],
    }
  end

  def notification_subscriber(payload)
    token = payload['userId'].is_a?(Hash) ? payload['userId']['uuid'] : payload['userId']
    return if token.blank?

    Subscriber.find_by_token(token)
  end

  # NOTE(ayrton) Segment requires a `user_id` or anonymous_id`, since we don't
  # have a concept of anonymous ids we implement something that is good enough.
  # If our system implemented global guest uids, replace here.
  def user_or_anonymous_id(subscriber)
    return { user_id: subscriber.user_id } if subscriber.user_id.present?

    { anonymous_id: "notification_subscriber_#{ subscriber.id }" }
  end
end
