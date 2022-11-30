# frozen_string_literal: true

module Graph::Types
  class Reviews::CurrentlyUsingType < BaseEnum
    graphql_name 'ReviewCurrentlyUsing'

    Review.currently_usings.each do |k, v|
      value k, v
    end
  end
end
