# frozen_string_literal: true

module API::V2::Types
  class GoalsOrderType < BaseEnum
    value 'COMPLETED_AT', 'Returns Goals in descending order of completion date.'
    value 'DUE_AT', 'Returns Goals in ascending order of due date.'
    value 'NEWEST', 'Returns Goals in descending order of creation date.'
  end
end
