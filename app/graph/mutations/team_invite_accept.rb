# frozen_string_literal: true

module Graph::Mutations
  class TeamInviteAccept < BaseMutation
    argument_record :invite, ::Team::Invite, required: true

    require_current_user

    def perform(invite:)
      # TODO(vlad): Handle if invate is via emal
      return error :user_id, :invalid_user if invite.user.id != current_user.id

      ::Teams.invite_accept(invite: invite)
    end
  end
end
