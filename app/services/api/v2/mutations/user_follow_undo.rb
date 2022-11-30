# frozen_string_literal: true

module API::V2::Mutations
  class UserFollowUndo < BaseMutation
    description 'Stop following a User as Viewer. Returns the un-followed User.'

    argument_record :user, User, description: 'ID of the User to stop following.'

    returns API::V2::Types::UserType

    def perform(user:)
      Following.unfollow(user: current_user, unfollows: user)
      user
    end
  end
end
