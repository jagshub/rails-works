# frozen_string_literal: true

module Jobs
  module Newsletter
    module Subscriptions
      extend self

      NEVER_SUBSCRIBED = 'never_subscribed'
      SUBSCRIBED = 'subscribed'
      UNSUBSCRIBED = 'unsubscribed'

      STATES = [NEVER_SUBSCRIBED, SUBSCRIBED, UNSUBSCRIBED].freeze

      def set(user: nil, email: nil, status:)
        email ||= user.email if user.present?

        return false unless email.present? && status.present?

        subscriber = Subscribers.register(user: user, email: email)
        subscriber.update(jobs_newsletter_subscription: status)
      rescue Subscribers::Register::DuplicatedSubscriberError
        false
      end
    end
  end
end
