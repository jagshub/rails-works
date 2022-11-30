# frozen_string_literal: true

module Notifications
  class DeliverNewsletterWorker < ApplicationJob
    include ActiveJobHandleNetworkErrors
    include ActiveJobHandlePostgresErrors

    queue_as :newsletters

    def perform(kind:, object:, subscriber_ids:)
      Newsletter::Counters.increment(object, 'start')

      notifications = subscriber_ids.map do |id|
        create_notification kind: kind, object: object, subscriber_id: id
      end.compact

      Newsletter::Counters.increment_by(object, notifications.size - subscriber_ids.size, 'missing') if notifications.size != subscriber_ids.size

      events = create_events(notifications)

      post_cache = Newsletter::Content::PostCache.new
      ads_cache = Ads::NewsletterAdsCache.new(object)

      messages = events.select { |event| event.subscriber.email }.map do |event|
        Newsletter::Email.new(
          event,
          sponsor: ads_cache.get_newsletter_sponsor,
          post_ad: ads_cache.get_newsletter_post_ad,
          cache: post_cache,
        ).to_mailjet_params
      end

      if messages.any?
        Newsletter::Counters.increment(object, 'sending')
        send_messages(messages)
        Newsletter::Counters.increment(object, 'send')
      else
        Newsletter::Counters.increment(object, 'skip')
      end

      External::SegmentApi.flush
    rescue ActiveRecord::ConnectionTimeoutError, RestClient::BadRequest
      notifications&.each(&:destroy!)
      retry_job wait: 2.minutes
    rescue StandardError => e
      notifications&.each(&:destroy!)
      raise e
    end

    private

    def create_events(notifications)
      notifications.map do |notification|
        NotificationEvent.create!(
          notification_id: notification.id,
          channel_name: 'email',
          status: :sent,
          sent_at: Time.current,
        )
      end
    end

    def send_messages(messages)
      Mailjet::Send.create(messages: messages)
    end

    def create_notification(**args)
      Notifications::Helpers::CreateNotification.call(**args)
    rescue ActiveRecord::InvalidForeignKey
      nil
    end
  end
end
