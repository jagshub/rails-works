# frozen_string_literal: true

module Graph::Types
  class Team::InviteStatusEnum < Graph::Types::BaseEnum
    graphql_name 'TeamInviteStatusEnum'

    ::Team::Invite.statuses.values.each do |status_value|
      value status_value
    end
  end
end
