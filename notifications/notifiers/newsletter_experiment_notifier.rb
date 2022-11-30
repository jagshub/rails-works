# frozen_string_literal: true

module Notifications::Notifiers::NewsletterExperimentNotifier
  extend Notifications::Notifiers::BaseNotifier
  extend self

  BATCH_SIZE = 500

  def channels
    {
      email: {
        priority: :mandatory,
        # NOTE(rstankov): Ignore settings, because we only schedule newsletter subscribers to receive notification
        user_setting: false,
      },
    }
  end

  def mailer(notification)
    NotificationMailer.newsletter_notification(notification)
  end

  def fan_out(object, **_args)
    return unless object.present? || object.variants.present?

    subscribers = Newsletter::Experiment::UserSet.call(test_count: object.test_count,
                                                       variant_count: object.variants.count,
                                                       kind: object.newsletter.kind)

    if subscribers.blank?
      ErrorReporting.report_warning_message('subscribers empty for newsletter_experiment')

      return
    end

    variants = object.variants
    stack_filled = [true] * variants.count

    while stack_filled.any?
      stack_filled.map!.with_index do |filled, index|
        if filled
          trigger_send variants[index], subscribers[index].pop(BATCH_SIZE)

          subscribers[index].any?
        else
          false
        end
      end
    end

    variants.each { |variant| variant.update! status: 'sent' }
  end

  private

  def trigger_send(variant, subscribers)
    threshold = 60
    ids = []

    variant.update! status: 'sending'

    subscribers.each do |id|
      ids << id
      if ids.length % threshold == 0
        schedule_deliver variant, ids
        ids = []
      end
    end

    schedule_deliver variant, ids unless ids.empty?
  end

  def schedule_deliver(variant, ids)
    Notifications::DeliverNewsletterWorker.perform_later kind: 'newsletter_experiment', object: variant, subscriber_ids: ids
  end
end
