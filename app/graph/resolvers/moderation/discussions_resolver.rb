# frozen_string_literal: true

class Graph::Resolvers::Moderation::DiscussionsResolver < Graph::Resolvers::BaseSearch
  type Graph::Types::Discussion::ThreadType.connection_type, null: false

  scope { Discussion::Thread.not_trashed }

  class FilterType < Graph::Types::BaseEnum
    graphql_name 'ModerationDiscussionsFilter'

    value 'RECENT'
    value 'FEATURED'
    value 'PINNED'
    value 'TRENDING'
    value 'PENDING'
    value 'APPROVED'
    value 'REJECTED'
  end

  option :filter, type: FilterType, default: 'RECENT'

  private

  def apply_filter_with_featured(scope)
    scope.where(featured_at: Time.current.to_date)
  end

  def apply_filter_with_recent(scope)
    ModerationLog.exclude_moderated(scope).order(created_at: :desc)
  end

  def apply_filter_with_pinned(scope)
    scope.pinned
  end

  def apply_filter_with_trending(scope)
    scope.trending
  end

  def apply_filter_with_pending(scope)
    scope.where(status: 'pending').order(created_at: :desc)
  end

  def apply_filter_with_approved(scope)
    scope.where(status: 'approved').order(created_at: :desc)
  end

  def apply_filter_with_rejected(scope)
    scope.where(status: 'rejected').order(created_at: :desc)
  end
end
