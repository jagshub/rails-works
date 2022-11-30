# frozen_string_literal: true

module Graph::Types
  class UpcomingPageSubscriberSearchType < BaseObject
    graphql_name 'UpcomingPageSubscriberSearch'

    extend Graph::Utils::AuthorizeRead

    field :id, ID, null: false
    field :name, String, null: false
    field :upcoming_page, Graph::Types::UpcomingPageType, null: false
    field :filters, null: false, resolver: Graph::Resolvers::UpcomingPages::SubscriberFiltersResolver, extras: [:path]
  end
end
