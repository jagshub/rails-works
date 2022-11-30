# frozen_string_literal: true

module Graph::Types
  class ShipContactType < BaseObject
    graphql_name 'ShipContact'

    extend Graph::Utils::AuthorizeMantain

    field :id, ID, null: false
    field :email, String, null: true
    field :is_imported, Boolean, null: false, method: :from_import?
    field :upcoming_page_with_fallback, Graph::Types::UpcomingPageType, resolver: Graph::Resolvers::Ships::Contacts::UpcomingPageWithFallbackResolver
    field :message_deliveries, [Graph::Types::UpcomingPageMessageDeliveryType], null: false

    association :user, Graph::Types::UserType, null: true
    association :clearbit_person_profile, Graph::Types::ClearbitPersonalProfileType, null: true
    association :answers, [Graph::Types::UpcomingPageQuestionAnswerType], null: false
    association :active_subscribers, [Graph::Types::UpcomingPageSubscriberType], null: false

    def message_deliveries
      object.message_deliveries.from_message
    end
  end
end
