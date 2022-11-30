# frozen_string_literal: true

class Mobile::Graph::Resolvers::Topics::Posts < Mobile::Graph::Resolvers::BaseSearchResolver
  scope { ::Posts::Ranking.apply(object.posts.visible.alive.featured, top: true) }

  type Mobile::Graph::Types::PostType.connection_type, null: false

  class Period < Mobile::Graph::Types::BaseEnum
    graphql_name 'TopicPostsPeriod'
    value 'this_year'
    value 'last_30_days'
    value 'this_week'
    value 'today'
    value 'all'
  end

  option :period, type: Period, default: 'all'

  private

  def apply_period_with_this_year(scope)
    now = Time.zone.now
    scope.where(featured_at: now.beginning_of_year..now.end_of_day)
  end

  def apply_period_with_last_30_days(scope)
    now = Time.zone.now
    scope.where(featured_at: now.months_ago(1)..now.end_of_day)
  end

  def apply_period_with_this_week(scope)
    now = Time.zone.now
    scope.where(featured_at: now.beginning_of_week..now.end_of_day)
  end

  def apply_period_with_today(scope)
    scope.for_featured_date(Time.zone.today)
  end

  def apply_period_with_all(scope)
    scope
  end
end
