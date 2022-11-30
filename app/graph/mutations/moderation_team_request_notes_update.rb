# frozen_string_literal: true

module Graph::Mutations
  class ModerationTeamRequestNotesUpdate < BaseMutation
    argument_record :team_request, Team::Request, authorize: :edit, required: true
    argument :moderation_notes, String, required: true

    returns Graph::Types::Team::RequestType

    def perform(team_request:, moderation_notes:)
      team_request.update!(moderation_notes: moderation_notes)
      team_request
    end
  end
end
