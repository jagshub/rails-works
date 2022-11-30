# frozen_string_literal: true

module Graph::Types
  class Payment::SubscriptionType < BaseObject
    graphql_name 'PaymentSubscription'

    extend Graph::Utils::AuthorizeRead

    field :id, ID, null: false
    field :project, String, null: false
    field :created_at, Graph::Types::DateTimeType, null: false
    field :user_canceled_at, Graph::Types::DateTimeType, null: true
    field :stripe_card, Graph::Types::Payment::CardType, null: true

    association :plan, Graph::Types::Payment::PlanType, null: false
    association :discount, Graph::Types::Payment::DiscountType, null: true

    def stripe_card
      External::StripeApi.fetch_customer_card(object.stripe_customer_id)
    end
  end
end
