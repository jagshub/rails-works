# frozen_string_literal: true

module Graph::Mutations
  class TeamRequestEmailResend < BaseMutation
    argument :token, String, required: true

    returns Graph::Types::Team::RequestType
    require_current_user

    def perform(token:)
      request = Team::Request.find_by!(verification_token: token)
      Teams.request_send_email_verification(request: request)
      request
    end
  end
end
