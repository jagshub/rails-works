# frozen_string_literal: true

module Graph::Mutations
  class GoldenKittyVoteCreate < BaseMutation
    argument_record :subject, GoldenKitty::Finalist, required: true

    returns Graph::Types::GoldenKittyFinalistType

    require_current_user

    def perform(subject:)
      return error :id, 'voting has ended' unless ApplicationPolicy.can?(current_user, :create_vote, subject)

      ::Voting.create(
        subject: subject,
        source: :web,
        user: current_user,
        request_info: request_info,
      )

      subject
    end
  end
end
