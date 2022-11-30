# frozen_string_literal: true

module API::V2Internal::Mutations
  class UserFollow < BaseMutation
    node :user, type: User

    returns API::V2Internal::Types::UserType

    def perform
      following = Following.follow(
        user: current_user,
        follows: node,
        source: :mobile,
        request_info: request_info,
      )

      following.following_user
    end
  end
end
