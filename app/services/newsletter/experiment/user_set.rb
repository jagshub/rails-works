# frozen_string_literal: true

module Newsletter::Experiment::UserSet
  extend self

  def call(test_count:, variant_count:, kind:)
    newsletter_id = previous_newsletter kind

    return [] if newsletter_id.blank?

    result = user_set(test_count, newsletter_id, kind)

    result = result.flatten

    difference = test_count - result.count

    result += normal_subscribers(result, kind, difference) if difference > 0

    result.shuffle.uniq.each_slice((test_count / variant_count).round).to_a
  end

  private

  def subscription(kind)
    kind == 'daily' ? Newsletter::Subscriptions::DAILY : Newsletter::Subscriptions::WEEKLY
  end

  def previous_newsletter(kind)
    Newsletter.sent.where(kind: kind).by_date.first&.id
  end

  def user_set(count, id, kind)
    NewsletterEvent
      .joins(:subscriber)
      .where(newsletter_id: id, event_name: 'open', newsletter_variant_id: nil)
      .where("notifications_subscribers.options->> 'newsletter_subscription' = ?", subscription(kind))
      .group('newsletter_events.subscriber_id')
      .order(Arel.sql('MIN(newsletter_events.time)'))
      .limit(count)
      .pluck('newsletter_events.subscriber_id')
  end

  def normal_subscribers(already_picked, kind, count)
    Subscriber
      .where(["notifications_subscribers.options->> 'newsletter_subscription' = ? and id not in (?)", subscription(kind), already_picked])
      .limit(count)
      .pluck('id')
  end
end
