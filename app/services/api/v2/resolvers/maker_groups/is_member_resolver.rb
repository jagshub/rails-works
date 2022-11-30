# frozen_string_literal: true

module API::V2::Resolvers
  class MakerGroups::IsMemberResolver < BaseResolver
    type Boolean, null: false

    def resolve
      return false unless can_resolve_private?

      IsMemberLoader.for(current_user).load(object)
    end

    class IsMemberLoader < GraphQL::Batch::Loader
      def initialize(user)
        @user = user
      end

      def perform(maker_groups)
        user_member_of_group_ids = @user.maker_group_ids

        maker_groups.each do |maker_group|
          fulfill maker_group, user_member_of_group_ids.include?(maker_group.id)
        end
      end
    end
  end
end
