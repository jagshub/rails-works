# frozen_string_literal: true

module Mobile::Graph::Mutations
  class VoteCreate < BaseMutation
    argument_record :subject, Vote::MOBILE_SUBJECT_TYPES.map(&:safe_constantize), required: true
    argument :source_component, String, required: false

    returns Mobile::Graph::Types::VotableInterfaceType

    def perform(subject:, source_component: nil)
      return subject if subject.created_at > Time.now.in_time_zone ## Do not add vote if scheduled date is in future.

      ApplicationPolicy.authorize!(current_user, :create, Vote.new(subject: subject))

      ::Voting.create(
        subject: subject,
        source: Mobile::ExtractInfoFromHeaders.get_mobile_source(context[:request]),
        source_component: source_component,
        user: current_user,
        request_info: request_info,
      )

      subject
    end
  end
end
