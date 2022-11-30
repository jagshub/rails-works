# frozen_string_literal: true

class API::V1::FollowingSerializer < API::V1::BaseSerializer
  delegated_attributes :id, :created_at, to: :resource
  attributes :user

  def user
    API::V1::BasicUserSerializer.new(resource.following_user, scope)
  end
end
