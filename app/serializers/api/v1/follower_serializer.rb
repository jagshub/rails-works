# frozen_string_literal: true

class API::V1::FollowerSerializer < API::V1::BaseSerializer
  delegated_attributes :id, :created_at, to: :resource
  attributes :user

  def user
    API::V1::BasicUserSerializer.new(resource.followed_by_user, scope)
  end
end
