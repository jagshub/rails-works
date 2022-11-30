# frozen_string_literal: true

class API::V1::BasicVoteSerializer < API::V1::BaseSerializer
  delegated_attributes :id, :created_at, :user_id, to: :resource

  attributes :post_id

  def post_id
    resource.subject_id
  end
end
