# frozen_string_literal: true

module Mobile::Graph::Mutations
  class VoteDestroy < BaseMutation
    argument_record :subject, Vote::MOBILE_SUBJECT_TYPES.map(&:safe_constantize), required: true

    require_current_user

    returns Mobile::Graph::Types::VotableInterfaceType

    def perform(subject:)
      ::Voting.destroy(subject: subject, user: current_user)

      subject
    end
  end
end
