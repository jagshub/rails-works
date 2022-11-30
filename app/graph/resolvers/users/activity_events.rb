# frozen_string_literal: true

class Graph::Resolvers::Users::ActivityEvents < Graph::Resolvers::BaseSearch
  scope { object.activity_events.order('occurred_at DESC') }

  class FilterEnum < Graph::Types::BaseEnum
    graphql_name 'UserActivityEventsFilterEnum'

    value 'all'
    value 'discussions'
    value 'reviews'
    value 'comments'
  end

  option :filter, type: FilterEnum, default: 'all'

  private

  def apply_filter_with_all(scope)
    scope
  end

  def apply_filter_with_discussions(scope)
    scope.where(subject_type: 'Discussion::Thread')
  end

  def apply_filter_with_reviews(scope)
    scope.where(subject_type: 'Review')
  end

  def apply_filter_with_comments(scope)
    scope.where(subject_type: 'Comment')
  end
end
