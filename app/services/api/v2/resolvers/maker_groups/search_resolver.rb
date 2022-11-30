# frozen_string_literal: true

module API::V2::Resolvers
  class MakerGroups::SearchResolver < BaseSearchResolver
    # NOTE(dhruvparmar372): Type needs to be explicitly set to connection_type
    # here because Member::BuildType.to_type_name fails here https://github.com/rmosolgo/graphql-ruby/blob/545a3acf885f97489c154eb63d7975228fa80a99/lib/graphql/schema/field.rb#L114
    # for some reason
    type ::API::V2::Types::MakerGroupType.connection_type, null: false

    scope { MakerGroup.accessible }

    option :user_id, type: GraphQL::Types::ID, description: 'Select MakerGroups that the User with the given ID is accepted member of.', with: :apply_user_id_filter
    option :order, type: API::V2::Types::MakerGroupsOrderType, description: 'Define order for the MakerGroups.', default: 'NEWEST'

    private

    def apply_user_id_filter(scope, value)
      return if value.blank?

      scope.joins(:members).where('maker_group_members.user_id': value, 'maker_group_members.state': 1)
    end

    def apply_order_with_newest(scope)
      scope.order(id: :desc)
    end

    def apply_order_with_last_active(scope)
      scope.by_activity
    end

    def apply_order_with_members_count(scope)
      scope.order(members_count: :desc)
    end

    def apply_order_with_goals_count(scope)
      scope.order(goals_count: :desc)
    end
  end
end
