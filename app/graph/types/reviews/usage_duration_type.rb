# frozen_string_literal: true

module Graph::Types
  class Reviews::UsageDurationType < BaseEnum
    graphql_name 'ReviewsUsageDuration'

    value 'never_used'
    value 'for_1_day'
    value 'for_1_week'
    value 'for_1_month'
    value 'for_1_year'
  end
end
