# frozen_string_literal: true

module Graph::Types
  class Team::MemberStatusEnum < Graph::Types::BaseEnum
    graphql_name 'TeamMemberStatusEnum'

    ::Team::Member.statuses.values.each do |status_value|
      value status_value
    end
  end
end
