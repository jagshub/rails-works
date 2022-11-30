# frozen_string_literal: true

class Graph::Resolvers::UpcomingPages::SearchResolver < Graph::Resolvers::BaseSearch
  scope { UpcomingPage.visible }

  class FilterType < Graph::Types::BaseEnum
    graphql_name 'UpcomingPageFilter'

    value 'FEATURED'
    value 'RELATED'
  end

  option :filter, type: FilterType, default: 'FEATURED'
  option :exclude, type: String, with: :apply_exclude
  option :query, type: String, with: :apply_query

  private

  def apply_filter_with_featured(scope)
    scope.for_listing.by_featured_at
  end

  def apply_filter_with_related(scope)
    exclude_ids = ::UpcomingPages::UserSubscriptions.call(current_user)
    scope.featured.by_featured_at.where.not(id: exclude_ids)
  end

  def apply_exclude(scope, value)
    upcoming_page = UpcomingPage.find_by(slug: value)
    scope.where.not(id: upcoming_page.id) if upcoming_page
  end

  def apply_query(scope, query)
    return scope if query&.strip.blank?

    scope.where_like_slow(:name, query)
  end
end
