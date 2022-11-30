# frozen_string_literal: true

module Mobile::Graph::Types
  class ReviewCurrentlyUsingType < BaseEnum
    graphql_name 'ReviewCurrentlyUsing'

    ::Review.currently_usings.each do |k, v|
      value k, v
    end
  end
end
