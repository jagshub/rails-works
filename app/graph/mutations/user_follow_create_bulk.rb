# frozen_string_literal: true

module Graph::Mutations
  class UserFollowCreateBulk < BaseMutation
    argument :source_component, String, required: false
    argument_records :users, User, required: true

    returns [Graph::Types::UserType]

    authorize :create, UserFriendAssociation

    require_current_user

    def perform(users:, source_component: nil)
      Following.bulk_follow(
        user: current_user,
        following: users,
        source: :web,
        source_component: source_component,
        request_info: request_info,
      )
      users
    end
  end
end
