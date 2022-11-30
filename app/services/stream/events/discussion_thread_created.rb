# frozen_string_literal: true

module Stream
  class Events::DiscussionThreadCreated < Events::Base
    BUFFER_FOR_DISCUSSION_TO_WARM_UP = 30.minutes.freeze
    WORKERS = [Stream::Activities::DiscussionStarted].freeze

    allowed_subjects [Discussion::Thread]
    allowed_keys_in_payload %i(thread_subject_type thread_subject_id)

    should_fanout do |event|
      discussion = event.subject
      return false if discussion.blank? || discussion.hidden? || discussion.trashed?
      return false if discussion.beta?

      discussion_owner = discussion.user
      return false if discussion_owner.blank? || discussion_owner.trashed? || discussion_owner.spammer? || discussion_owner.potential_spammer?

      true
    end

    fanout_workers do |_event|
      WORKERS.map { |worker| worker.set(wait: BUFFER_FOR_DISCUSSION_TO_WARM_UP) }
    end
  end
end
