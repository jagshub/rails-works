# frozen_string_literal: true

class API::V2Internal::Mutations::UserUnfollow < API::V2Internal::Mutations::BaseMutation
  node :user, type: User

  returns API::V2Internal::Types::UserType

  def perform
    Following.unfollow user: current_user, unfollows: node
    node
  end
end
