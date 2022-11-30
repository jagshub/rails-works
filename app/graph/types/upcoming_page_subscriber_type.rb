# frozen_string_literal: true

module Graph::Types
  class UpcomingPageSubscriberType < BaseObject
    graphql_name 'UpcomingPageSubscriber'

    field :id, ID, null: false
    field :created_at, Graph::Types::DateTimeType, null: true
    field :contact_id, ID, null: true
    field :contact, Graph::Types::ShipContactType, null: false, resolver: Graph::Resolvers::AuthorizationAssociation.build(:contact, type: Graph::Types::ShipContactType)
    field :answers, [Graph::Types::UpcomingPageQuestionAnswerType], null: false, resolver: Graph::Resolvers::AuthorizationAssociation.build(:answers, type: [Graph::Types::UpcomingPageQuestionAnswerType])
    field :segments, [Graph::Types::UpcomingPageSegmentType], null: false, resolver: Graph::Resolvers::AuthorizationAssociation.build(:segments, type: [Graph::Types::UpcomingPageSegmentType])

    association :upcoming_page, Graph::Types::UpcomingPageType, null: false

    def created_at
      return unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.created_at
    end

    def contact_id
      return unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.ship_contact_id
    end
  end
end
