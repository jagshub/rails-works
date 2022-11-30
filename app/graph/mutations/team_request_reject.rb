# frozen_string_literal: true

module Graph::Mutations
  class TeamRequestReject < BaseMutation
    argument_record :team_request, Team::Request, authorize: :edit

    returns Graph::Types::Team::RequestType
    require_current_user

    def perform(team_request:)
      Teams.request_reject(
        request: team_request,
        status_changed_by: current_user,
      )
    end
  end
end
