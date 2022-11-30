# frozen_string_literal: true

module API::V2::Mutations
  class UserFollow < BaseMutation
    description 'Follow a User as Viewer. Returns the followed User.'

    argument_record :user, User, description: 'ID of the User to follow.'

    returns API::V2::Types::UserType

    def perform(user:)
      Following.follow(
        user: current_user,
        follows: user,
        source: :api,
        request_info: request_info.merge(oauth_application_id: current_application.id),
      )

      user
    end
  end
end
