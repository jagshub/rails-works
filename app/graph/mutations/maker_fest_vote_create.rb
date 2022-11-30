# frozen_string_literal: true

module Graph::Mutations
  class MakerFestVoteCreate < BaseMutation
    argument_record :subject, MakerFest::Participant, required: true

    require_current_user

    def perform
      return if MakerFest::Submission.voting_ended?
      return if subject.blank?

      ::Voting.create(
        subject: subject,
        source: :web,
        user: current_user,
        request_info: request_info,
      )

      nil
    end
  end
end
