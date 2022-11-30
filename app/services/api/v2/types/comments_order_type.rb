# frozen_string_literal: true

module API::V2::Types
  class CommentsOrderType < BaseEnum
    value 'NEWEST', 'Returns Comments in descending order of creation date.'
    value 'VOTES_COUNT', 'Returns Comments in descending order of votes count.'
  end
end
