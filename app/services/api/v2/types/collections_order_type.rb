# frozen_string_literal: true

module API::V2::Types
  class CollectionsOrderType < BaseEnum
    value 'NEWEST', 'Returns Collections in descending order of creation date.'
    value 'FOLLOWERS_COUNT', 'Returns Collections in descending order of followers count.'
    value 'FEATURED_AT', 'Returns Collections in descending order of featured date.'
  end
end
