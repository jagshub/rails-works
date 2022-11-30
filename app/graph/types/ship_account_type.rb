# frozen_string_literal: true

module Graph::Types
  class ShipAccountType < BaseObject
    graphql_name 'ShipAccount'

    field :id, ID, null: false
    field :name, ID, null: true
    field :subscription, Graph::Types::ShipSubscriptionType, null: false

    def subscription
      return unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.subscription
    end

    field :first_upcoming_page, Graph::Types::UpcomingPageType, null: true

    association :members, [Graph::Types::UserType], null: false
    association :user, Graph::Types::UserType, null: false

    # NOTE(rstankov): This is used just for the layout requiring upcoming page
    def first_upcoming_page
      object.upcoming_pages.not_trashed.by_featured_at.first
    end
  end
end
