# frozen_string_literal: true

module Graph::Mutations
  class TeamInviteResend < BaseMutation
    argument_record :team_invite, ::Team::Invite, authorize: :edit
    returns Graph::Types::Team::InviteType

    require_current_user

    def perform(team_invite:)
      TeamMailer.invite_received(team_invite).deliver_later

      team_invite
    end
  end
end
