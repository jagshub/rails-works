# frozen_string_literal: true

module Graph::Mutations
  class GoldenKittyVoteDestroy < BaseMutation
    argument_record :subject, GoldenKitty::Finalist, required: true

    returns Graph::Types::GoldenKittyFinalistType

    require_current_user

    def perform(subject:)
      return error :id, 'voting has ended' unless ApplicationPolicy.can?(current_user, :destroy_vote, subject)

      ::Voting.destroy(subject: subject, user: current_user)

      subject
    end
  end
end
