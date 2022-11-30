# frozen_string_literal: true

class Mobile::Graph::Resolvers::Users::Badges < Mobile::Graph::Resolvers::BaseSearchResolver
  scope { object.badges.visible }

  type Mobile::Graph::Types::UserBadgeType.connection_type, null: false

  class FilterType < Mobile::Graph::Types::BaseEnum
    graphql_name 'UserBadgesFilter'

    value 'COMPLETED'
    value 'IN_PROGRESS'
  end

  option :filter, type: FilterType
  option :showcase, type: Boolean, with: :apply_showcase
  option :award_kind, type: Mobile::Graph::Types::UserBadgeAwardKindType

  private

  def apply_filter_with_completed(scope)
    scope.with_data(status: 'awarded_to_user_and_visible')
  end

  def apply_filter_with_in_progress(scope)
    scope.with_data(status: 'in_progress')
  end

  def apply_showcase(scope, value)
    return scope if value.nil?

    if value
      scope.with_data(showcased: true)
    else
      scope.with_data(showcased: false).or(
        scope.where("data -> 'showcased' is null"),
      )
    end
  end

  Badges::Award.identifiers.keys.each do |kind|
    define_method("apply_award_kind_with_#{ kind }") do |scope|
      scope.by_identifier(kind)
    end
  end
end
