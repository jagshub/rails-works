# frozen_string_literal: true

module Graph::Mutations
  class TeamRequestEmailConfirm < BaseMutation
    argument :token, String, required: true

    returns Graph::Types::Team::RequestType
    require_current_user

    def perform(token:)
      Teams.request_verify_by_token(token: token, user: current_user)
    rescue Teams::Requests::Verification::VerificationError => e
      error :base, e.message
    end
  end
end
