# frozen_string_literal: true

class Graph::Resolvers::Users::AllPostsSearchResolver < Graph::Resolvers::BaseSearch
  scope { Post.not_trashed.distinct.by_featured_at } ## only including active

  class FilterType < Graph::Types::BaseEnum
    graphql_name 'AllPostsFilter'

    value 'HUNTED'
    value 'MADE'
    value 'SCHEDULED'
    value 'POSTED'
    value 'ALL'
  end

  option :filter, type: FilterType, default: 'ALL'

  private

  def apply_filter_with_hunted(scope)
    scope.where(user_id: object.id)
  end

  def apply_filter_with_made(scope)
    scope.merge(object.products)
  end

  def apply_filter_with_scheduled(scope)
    scope.where(Post.arel_table[:scheduled_at].gt(Time.now.in_time_zone)).where(user_id: object.id)
  end

  def apply_filter_with_posted(scope)
    scope.where(Post.arel_table[:scheduled_at].lteq(Time.now.in_time_zone)).where(user_id: object.id)
  end

  def apply_filter_with_all(scope)
    scope.merge(object.hunted_or_made)
  end
end
