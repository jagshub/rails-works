# frozen_string_literal: true

module API::V2::Types
  class PostsOrderType < BaseEnum
    value 'FEATURED_AT', 'Returns Posts in descending order of featured date.'
    value 'VOTES', 'Returns Posts in descending order of votes count.'
    value 'RANKING', 'Returns Posts in descending order of ranking.'
    value 'NEWEST', 'Returns Posts in descending order of creation date.'
  end
end
