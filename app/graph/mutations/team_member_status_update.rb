# frozen_string_literal: true

module Graph::Mutations
  class TeamMemberStatusUpdate < BaseMutation
    argument_record :team_member, Team::Member, authorize: :update
    argument :status, Graph::Types::Team::MemberStatusEnum, required: true

    returns Graph::Types::Team::MemberType
    require_current_user

    def perform(team_member:, status:)
      team_member.update!(status: status)
      team_member
    end
  end
end
