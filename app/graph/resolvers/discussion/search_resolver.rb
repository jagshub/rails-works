# frozen_string_literal: true

class Graph::Resolvers::Discussion::SearchResolver < Graph::Resolvers::BaseSearch
  scope do
    object.present? ? object.discussions.where(status: 'approved') : Discussion::Thread.where(status: 'approved')
  end

  type Graph::Types::Discussion::ThreadType.connection_type, null: false

  class OrderEnum < Graph::Types::BaseEnum
    graphql_name 'DiscussionSearchOrderEnum'

    value 'popular'
    value 'new'
  end

  class WindowEnum < Graph::Types::BaseEnum
    graphql_name 'DiscussionSearchWindowEnum'

    value 'now'
    value 'week'
    value 'month'
    value 'year'
    value 'all'
  end

  option :query, type: String, with: :apply_query
  option :category, type: String, with: :apply_in_category
  option :exclude_slug, type: String, with: :apply_exclude_by_slug

  # NOTE(DZ): Following options need to be declared in order be correct
  [
    [:pinned_first, type: Boolean, with: :apply_by_pinned_first],
    [:order, type: OrderEnum],
    [:window, type: WindowEnum],
  ].each { |args| option *args }

  private

  def apply_by_pinned_first(scope, value)
    return scope unless value

    scope.order(Arel.sql('CASE pinned WHEN true THEN 1 ELSE 0 END DESC'))
  end

  def apply_window_with_now(scope)
    scope.order(Arel.sql("date_trunc('day', discussion_threads.created_at) DESC")).by_popular
  end

  def apply_window_with_week(scope)
    scope.order(Arel.sql("date_trunc('week', discussion_threads.created_at) DESC")).by_popular
  end

  def apply_window_with_month(scope)
    scope.order(Arel.sql("date_trunc('month', discussion_threads.created_at) DESC")).by_popular
  end

  def apply_window_with_year(scope)
    scope.order(Arel.sql("date_trunc('year', discussion_threads.created_at) DESC")).by_popular
  end

  def apply_window_with_all(scope)
    scope.by_popular
  end

  def apply_order_with_popular(scope)
    # NOTE(DZ): Phantom sort order. Popular needs to be paired with `window`
    scope
  end

  def apply_order_with_new(scope)
    scope.order(created_at: :DESC)
  end

  def apply_exclude_by_slug(scope, value)
    return scope if value.blank?

    scope.where.not(slug: value)
  end

  def apply_in_category(scope, value)
    return scope if value.blank?

    category = Discussion::Category.find_by_slug value
    return Discussion::Thread.none unless category

    scope.joins(:category_associations).where('category_id = ?', category.id)
  end

  def apply_query(scope, query)
    return scope if query&.strip.blank?

    scope.where_like_slow(:title, query)
  end
end
