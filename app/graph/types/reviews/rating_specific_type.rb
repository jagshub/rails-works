# frozen_string_literal: true

module Graph::Types
  class Reviews::RatingSpecificType < BaseNode
    graphql_name 'ReviewRatingSpecific'

    field :rating, Int, null: false
    field :count, Int, null: false
  end
end
