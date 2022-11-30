# frozen_string_literal: true

module Graph::Mutations
  class MakerFestVoteDestroy < BaseMutation
    argument_record :subject, MakerFest::Participant, required: true

    require_current_user

    def perform(subject:)
      return if MakerFest::Submission.voting_ended?
      return if subject.blank?

      ::Voting.destroy(subject: subject, user: current_user)

      nil
    end
  end
end
