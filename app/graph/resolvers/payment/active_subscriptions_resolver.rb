# frozen_string_literal: true

module Graph::Resolvers
  class Payment::ActiveSubscriptionsResolver < Graph::Resolvers::Base
    type [Graph::Types::Payment::SubscriptionType], null: false

    def resolve
      return [] if current_user.blank?

      current_user.payment_subscriptions.active.reverse_chronological
    end
  end
end
