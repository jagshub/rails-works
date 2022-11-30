# frozen_string_literal: true

module Notifications::Notifiers::NewsletterNotifier
  extend Notifications::Notifiers::BaseNotifier
  extend self

  def channels
    {
      email: {
        priority: :mandatory,
        # NOTE(rstankov): Ignore settings, because we only schedule newsletter subscribers to receive notification
        user_setting: false,
      },
    }
  end

  def subscribers(newsletter)
    already_sent = fetch_already_sent_experiments newsletter

    scope = Subscriber.with_newsletter_subscription(newsletter.subscription_kind).with_email_confirmed
    scope = scope.where.not(id: already_sent) if already_sent.any?
    scope.select(:id)
  end

  def send_notification?(event, *_args)
    subscriber = event.subscriber
    newsletter = event.notifyable

    newsletter.subscription_kind == subscriber.newsletter_subscription
  end

  # NOTE(DZ): Newsletter does not follow the notifier pattern. Instead, it uses
  # it's own worker in #fan_out to send newsletters
  def mailer(notification)
    NotificationMailer.newsletter_notification(notification)
  end

  def fan_out(object, kind:)
    # Note(rstankov): Performance testing determines which is the best threshold
    #   Mailjet batch limit is about 50MB per request, its good to stay about 25MB max
    threshold = 50
    ids = []

    Newsletter::Counters.start_fan_out(object)
    Newsletter::Counters.increment(object, 'fan_out')

    subscribers(object).find_each do |subscriber|
      ids << subscriber.id
      if ids.length % threshold == 0
        Newsletter::Counters.increment(object, 'job_enqueue')
        Notifications::DeliverNewsletterWorker.perform_later kind: kind, object: object, subscriber_ids: ids

        ids = []
      end
    end

    unless ids.empty?
      Newsletter::Counters.increment(object, 'job_enqueue')
      Notifications::DeliverNewsletterWorker.perform_later kind: kind, object: object, subscriber_ids: ids
    end

    Newsletter::Counters.stop_fan_out(object)
  end

  private

  def fetch_already_sent_experiments(newsletter)
    return [] unless newsletter.experiment&.sent?

    NotificationLog.joins('INNER JOIN notification_events on notification_events.notification_id=notification_logs.id').where(kind: :newsletter_experiment, notifyable_type: 'NewsletterVariant', notifyable_id: newsletter.experiment.variant_ids).pluck(:subscriber_id)
  end
end
