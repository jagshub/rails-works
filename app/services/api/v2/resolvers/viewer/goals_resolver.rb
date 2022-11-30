# frozen_string_literal: true

module API::V2::Resolvers
  class Viewer::GoalsResolver < BaseSearchResolver
    # NOTE(dhruvparmar372): Type needs to be explicitly set to connection_type
    # here because Member::BuildType.to_type_name fails here https://github.com/rmosolgo/graphql-ruby/blob/545a3acf885f97489c154eb63d7975228fa80a99/lib/graphql/schema/field.rb#L114
    # for some reason
    type ::API::V2::Types::GoalType.connection_type, null: false

    scope { object.goals }

    option :current, type: GraphQL::Types::Boolean, description: 'Select Goals which are set as current or not current depending on given value.', with: :apply_current_filter
    option :order, type: API::V2::Types::GoalsOrderType, description: 'Define order for the Goals.', default: 'NEWEST'

    private

    def apply_current_filter(scope, value)
      return if value.blank? || !value

      scope.current
    end

    def apply_order_with_newest(scope)
      scope.by_date
    end

    def apply_order_with_completed_at(scope)
      scope.order('completed_at DESC NULLS LAST')
    end

    def apply_order_with_due_at(scope)
      scope.order('due_at ASC NULLS LAST')
    end
  end
end
