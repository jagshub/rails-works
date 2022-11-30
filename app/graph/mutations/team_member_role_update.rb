# frozen_string_literal: true

module Graph::Mutations
  class TeamMemberRoleUpdate < BaseMutation
    argument_record :team_member, Team::Member, authorize: :update
    argument :role, Graph::Types::Team::MemberRoleEnum, required: true

    returns Graph::Types::Team::MemberType
    require_current_user

    def perform(team_member:, role:)
      team_member.update!(role: role)
      team_member
    end
  end
end
