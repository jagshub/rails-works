# frozen_string_literal: true

module Anthologies::Stories
  module Newsletter
    module Subscriptions
      extend self

      SUBSCRIBED = 'subscribed'
      UNSUBSCRIBED = 'unsubscribed'

      STATES = [SUBSCRIBED, UNSUBSCRIBED].freeze

      def set(user: nil, email: nil, status:)
        email ||= user.email if user.present?

        return false unless email.present? && status.present?

        subscriber = Subscribers.register(user: user, email: email)
        subscriber.update!(stories_newsletter_subscription: status)
      end
    end
  end
end
