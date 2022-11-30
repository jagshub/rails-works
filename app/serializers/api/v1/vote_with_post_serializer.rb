# frozen_string_literal: true

class API::V1::VoteWithPostSerializer < API::V1::BasicVoteSerializer
  # Note(andreasklinger): according to documentation the decision what to load
  #   should also be possible with `include_x?` (deprecated?) and `filter`.
  #   But i couldn't get neither to work so i went with a "split" of models for now.
  attributes :post

  def post
    API::V1::BasicPostSerializer.new(resource.subject, scope)
  end
end
