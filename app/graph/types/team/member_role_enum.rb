# frozen_string_literal: true

module Graph::Types
  class Team::MemberRoleEnum < Graph::Types::BaseEnum
    graphql_name 'TeamMemberRoleEnum'

    ::Team::Member.roles.values.each do |status_value|
      value status_value
    end
  end
end
