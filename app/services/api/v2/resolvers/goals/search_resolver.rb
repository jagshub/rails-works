# frozen_string_literal: true

module API::V2::Resolvers
  class Goals::SearchResolver < BaseSearchResolver
    # NOTE(dhruvparmar372): Type needs to be explicitly set to connection_type
    # here because Member::BuildType.to_type_name fails here https://github.com/rmosolgo/graphql-ruby/blob/545a3acf885f97489c154eb63d7975228fa80a99/lib/graphql/schema/field.rb#L114
    # for some reason
    type ::API::V2::Types::GoalType.connection_type, null: false

    scope { Goal.includes(:user) }

    option :user_id, type: GraphQL::Types::ID, description: 'Select Goals that are created by User with the given ID.', with: :apply_user_id_filter
    option :maker_group_id, type: GraphQL::Types::ID, description: 'Select Goals that are created in the MakerGroup(Space) with given ID.', with: :apply_maker_group_id_filter
    option :maker_project_id, type: GraphQL::Types::ID, description: 'Select Goals that are created in the MakerProject with given ID.', with: :apply_maker_project_id_filter
    option :completed, type: GraphQL::Types::Boolean, description: 'Select Goals that have been completed or not completed depending on given value.', with: :apply_completed_filter
    option :order, type: API::V2::Types::GoalsOrderType, description: 'Define order for the Goals.', default: 'NEWEST'

    private

    def apply_user_id_filter(scope, value)
      return if value.blank?

      scope.where(user_id: value)
    end

    def apply_maker_group_id_filter(scope, value)
      return if value.blank?

      scope.where(maker_group_id: value)
    end

    def apply_maker_project_id_filter(scope, _value)
      scope
    end

    def apply_completed_filter(scope, value)
      value ? scope.completed : scope.uncompleted
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
