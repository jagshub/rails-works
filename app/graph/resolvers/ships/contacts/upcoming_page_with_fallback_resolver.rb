# frozen_string_literal: true

class Graph::Resolvers::Ships::Contacts::UpcomingPageWithFallbackResolver < Graph::Resolvers::Base
  type Graph::Types::UpcomingPageType, null: true

  def resolve
    return unless ApplicationPolicy.can?(current_user, ApplicationPolicy::MAINTAIN, object)

    object.upcoming_pages.not_trashed.first || object.account.upcoming_pages.not_trashed.first
  end
end
