# frozen_string_literal: true

module API::V2::Types
  class TopicsOrderType < BaseEnum
    value 'NEWEST', 'Returns Topics in descending order of creation date.'
    value 'FOLLOWERS_COUNT', 'Returns Topics in descending order of followers count.'
  end
end
