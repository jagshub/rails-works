# frozen_string_literal: true

module Stream
  class Events::VoteCreated < Events::Base
    event_name 'upvote'
    allowed_subjects [Vote]
    allowed_keys_in_payload %i(vote_subject_type vote_subject_id)

    should_fanout do |event|
      event.subject.reload.credible
    end

    fanout_workers { |_event| [Stream::Activities::VoteCreated] }
  end
end
