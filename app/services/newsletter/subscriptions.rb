# frozen_string_literal: true

module Newsletter::Subscriptions
  extend self

  DAILY = 'Daily (Mon - Fri)'
  WEEKLY = 'Weekly'
  UNSUBSCRIBED = 'Unsubscribe'

  STATES = [DAILY, WEEKLY, UNSUBSCRIBED].freeze

  def statuses
    STATES
  end

  def active?(user: nil, email: nil, subscriber: nil)
    if subscriber
      subscriber.newsletter_subscription != UNSUBSCRIBED
    else
      status_for(user: user, email: email) != UNSUBSCRIBED
    end
  end

  def status_for(user: nil, email: nil)
    subscriber = find_or_build_subscriber(user: user, email: email)
    subscriber.newsletter_subscription
  end

  def set(user: nil, email: nil, status:, tracking_options: {})
    email ||= user.email if user.present?

    return false unless email.present? && status.present?

    subscriber = Subscribers.register(user: user, email: email)
    is_changed = subscriber.newsletter_subscription != status
    result = subscriber.update newsletter_subscription: status
    ::Metrics::Newsletter::LogSubscriptionChange.call(subscriber: subscriber, tracking_options: tracking_options) if result && is_changed
    result
  rescue Subscribers::Register::DuplicatedSubscriberError
    false
  end

  private

  def find_or_build_subscriber(user:, email:)
    if user
      user.subscriber || Subscriber.without_user.find_by_email(email) || user.build_subscriber
    else
      Subscriber.find_by_email(email) || Subscriber.new
    end
  end
end
