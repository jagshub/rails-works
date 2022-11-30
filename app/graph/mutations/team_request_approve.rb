# frozen_string_literal: true

module Graph::Mutations
  class TeamRequestApprove < BaseMutation
    argument_record :team_request, Team::Request
    argument :role, Graph::Types::Team::MemberRoleEnum, required: false

    returns Graph::Types::Team::RequestType
    require_current_user

    def perform(team_request:, role: nil)
      authorize!(team_request, role)

      Teams.request_approve(
        request: team_request,
        approval_type: :manual,
        status_changed_by: current_user,
        role: role,
      )
    end

    private

    def authorize!(team_request, requested_role)
      permission = requested_role == 'owner' ? :maintain : :edit

      ApplicationPolicy.authorize! current_user, permission, team_request
    end
  end
end
