# frozen_string_literal: true

module Graph::Mutations
  class VoteCreate < BaseMutation
    argument_record :subject, Vote::SUBJECT_TYPES.map(&:safe_constantize), required: true
    argument :source_component, String, required: false

    returns Graph::Types::VotableInterfaceType

    def perform(subject:, source_component: nil)
      # NOTE(rstankov): Voting is restricted for scheduled posts
      return subject if subject.created_at > Time.now.in_time_zone ## Do not add vote if scheduled date is in future.

      ApplicationPolicy.authorize!(current_user, :create, Vote.new(subject: subject))

      # NOTE(DZ): Update clearbit profile for user
      ClearbitProfiles.enqueue_for_enrich(current_user)

      ::Voting.create(
        subject: subject,
        source: :web,
        source_component: source_component,
        user: current_user,
        request_info: request_info,
      )

      subject
    end
  end
end
