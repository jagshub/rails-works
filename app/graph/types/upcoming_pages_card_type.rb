# frozen_string_literal: true

module Graph::Types
  class UpcomingPagesCardType < BaseNode
    graphql_name 'UpcomingPagesCard'

    field :upcoming_pages, [Graph::Types::UpcomingPageType], null: false
  end
end
