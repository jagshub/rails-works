# frozen_string_literal: true

module Stream
  class Events::ReviewCreated < Events::Base
    event_name 'review'
    allowed_subjects [Review]
    allowed_keys_in_payload %i(review_subject_type review_subject_id)

    should_fanout do |event|
      !event.subject.reload.hidden?
    end

    fanout_workers { |_event| [Stream::Activities::ReviewCreated] }
  end
end
