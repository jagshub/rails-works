# frozen_string_literal: true

module Mobile::Graph::Mutations
  class UserUnfollow < BaseMutation
    argument_record :user, User, required: true

    returns Mobile::Graph::Types::UserType

    authorize :destroy, UserFriendAssociation

    def perform(user:)
      Following.unfollow(user: current_user, unfollows: user)
      user.reload
    end
  end
end
