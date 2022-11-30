# frozen_string_literal: true

class Graph::Resolvers::Newsletters < Graph::Resolvers::BaseSearch
  scope { Newsletter.sent }

  class Filter < Graph::Types::BaseEnum
    graphql_name 'NewslettersFilter'

    value 'DAILY'
    value 'WEEKLY'
    value 'RELATED'
  end

  option :filter, type: Filter
  option :newer_than, type: GraphQL::Types::ID, with: :apply_newer_than

  private

  def apply_filter_with_daily(scope)
    scope.daily.by_sent_date
  end

  def apply_filter_with_weekly(scope)
    scope.weekly.by_sent_date
  end

  def apply_filter_with_related(scope)
    return scope if object.blank?

    scope.by_sent_date.where(kind: object.kind)
  end

  def apply_newer_than(scope, value)
    scope.where('id < ?', value.to_i).order('id desc')
  end
end
