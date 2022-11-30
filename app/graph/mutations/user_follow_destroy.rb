# frozen_string_literal: true

module Graph::Mutations
  class UserFollowDestroy < BaseMutation
    argument_record :user, User, required: true

    returns Graph::Types::UserType

    authorize :destroy, UserFriendAssociation

    def perform(user:)
      Following.unfollow(user: current_user, unfollows: user)
      user.reload
    end
  end
end
