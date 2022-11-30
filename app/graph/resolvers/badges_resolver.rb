# frozen_string_literal: true

class Graph::Resolvers::BadgesResolver < Graph::Resolvers::BaseSearch
  scope { object.badges }

  class SortEnum < Graph::Types::BaseEnum
    graphql_name 'BadgesSortEnum'

    value 'default'
    value 'date'
  end

  class BadgesTypeEnum < Graph::Types::BaseEnum
    graphql_name 'BadgesTypeEnum'

    value 'TopPostBadge'
    value 'GoldenKittyAwardBadge'
    value 'TopPostTopicBadge'
  end

  option :sort, type: SortEnum, default: 'default'
  option(:types, type: [BadgesTypeEnum], default: []) do |scope, value|
    if value.blank?
      scope
    else
      scope.select do |badge|
        value.map do |type|
          "Badges::#{ type }"
        end.include? badge.type
      end
    end
  end

  private

  def apply_sort_with_default(scope)
    scope.sort_by do |badge|
      get_score(badge)
    end.reverse
  end

  def apply_sort_with_date(scope)
    scope.by_created_at
  end

  def get_score(badge)
    case badge
    when Badges::TopPostBadge
      case badge.period
      when 'daily' then 1
      when 'weekly' then 2
      when 'montly' then 3
      when 'monthly' then 3
      else raise "Unknown period: #{ badge.period }"
      end
    when Badges::GoldenKittyAwardBadge then 5
    when Badges::TopPostTopicBadge then 0
    else 4
    end
  end
end
