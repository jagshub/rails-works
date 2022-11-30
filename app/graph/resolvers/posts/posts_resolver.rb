# frozen_string_literal: true

class Graph::Resolvers::Posts::PostsResolver < Graph::Resolvers::BaseSearch
  scope { Post }

  class OrderType < Graph::Types::BaseEnum
    graphql_name 'PostsOrder'

    value 'DAILY_RANK'
    value 'MONTHLY_RANK'
    value 'VOTES'
  end

  option :year, type: Integer, with: :for_year
  option :month, type: Integer, with: :for_month
  option :day, type: Integer, with: :for_day
  option :today, type: Boolean, with: :for_today
  option :query, type: String, with: :by_query
  option :featured, type: Boolean, with: :by_featured, default: true
  option :order, type: OrderType, default: 'VOTES'
  option :exclude_ids, type: [ID], with: :filter_excluded_ids

  def apply_order_with_daily_rank(scope)
    scope.order('daily_rank ASC')
  end

  def apply_order_with_monthly_rank(scope)
    scope.order('monthly_rank ASC')
  end

  def apply_order_with_votes(scope)
    scope.by_credible_votes
  end

  private

  def for_today(scope, value)
    scope.where_date_eq(:featured_at, Time.zone.today) if value
  end

  def for_year(scope, value)
    return if value.blank?

    scope.where('extract(year from featured_at) = ?', value)
  end

  def for_month(scope, value)
    return if value.blank?

    scope.where('extract(month from featured_at) = ?', value)
  end

  def for_day(scope, value)
    return if value.blank?

    scope.where('extract(day from featured_at) = ?', value)
  end

  def by_query(scope, value)
    return if value.blank?

    scope.where '(lower(name) LIKE :query)', query: LikeMatch.by_words(query)
  end

  def by_featured(scope, value)
    if value
      scope.featured
    else
      scope
    end
  end

  def filter_excluded_ids(scope, value)
    scope.where.not(id: value)
  end
end
