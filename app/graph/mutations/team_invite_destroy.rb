# frozen_string_literal: true

module Graph::Mutations
  class TeamInviteDestroy < BaseMutation
    argument_record :team_invite, ::Team::Invite, authorize: :edit
    returns Graph::Types::Team::InviteType

    require_current_user

    def perform(team_invite:)
      team_invite.destroy!
      team_invite
    end
  end
end
