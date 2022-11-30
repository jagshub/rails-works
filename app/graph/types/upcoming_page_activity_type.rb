# frozen_string_literal: true

module Graph::Types
  class UpcomingPageActivitySubjectType < BaseUnion
    graphql_name 'UpcomingPageActivitySubject'

    possible_types(
      Graph::Types::UpcomingPageMessageType,
      Graph::Types::UpcomingPageSurveyType,
    )
  end
end

module Graph::Types
  class UpcomingPageActivityType < BaseObject
    graphql_name 'UpcomingPageActivity'

    field :upcoming_page, Graph::Types::UpcomingPageType, null: false
    field :subject, Graph::Types::UpcomingPageActivitySubjectType, null: false
    field :subscriber, Graph::Types::UpcomingPageSubscriberType, null: false
    field :created_at, Graph::Types::DateTimeType, null: false
  end
end
