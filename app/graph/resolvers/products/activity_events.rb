# frozen_string_literal: true

class Graph::Resolvers::Products::ActivityEvents < Graph::Resolvers::BaseSearch
  scope { object.activity_events.order_for_feed }

  class FilterEnum < Graph::Types::BaseEnum
    graphql_name 'ActivityEventsFilterEnum'

    value 'all'
    value 'launches'
    value 'announcements'
    value 'stories'
  end

  option :filter, type: FilterEnum, default: 'all'

  private

  def apply_filter_with_all(scope)
    scope
  end

  def apply_filter_with_launches(scope)
    scope.where(subject_type: 'Post')
  end

  def apply_filter_with_announcements(scope)
    award_types = %w(Badges::TopPostBadge Badges::GoldenKittyAwardBadge)
    scope.where(subject_type: award_types)
  end

  def apply_filter_with_stories(scope)
    scope.where(subject_type: 'Anthologies::Story')
  end
end
