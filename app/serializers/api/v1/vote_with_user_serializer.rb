# frozen_string_literal: true

class API::V1::VoteWithUserSerializer < API::V1::BasicVoteSerializer
  attributes :user

  def user
    API::V1::BasicUserSerializer.new(resource.user, scope)
  end
end
