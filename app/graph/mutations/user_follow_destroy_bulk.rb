# frozen_string_literal: true

module Graph::Mutations
  class UserFollowDestroyBulk < BaseMutation
    argument_records :users, User, required: true

    returns [Graph::Types::UserType]

    authorize :destroy, UserFriendAssociation

    require_current_user

    def perform(users:)
      Following.bulk_unfollow(
        user: current_user,
        unfollowing: users,
      )
      users
    end
  end
end
