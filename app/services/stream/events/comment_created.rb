# frozen_string_literal: true

module Stream
  class Events::CommentCreated < Events::Base
    allowed_subjects [Comment]
    allowed_keys_in_payload %i(comment_subject_type comment_subject_id)

    should_fanout do |event|
      comment = event.subject
      return false if comment.hidden? || comment.mentioned_user_ids.size > 5

      request_info = event.payload.symbolize_keys.slice(:first_referer, :request_ip, :user_agent)
      Comments::SpamCheck.perform_now(comment: comment, request_info: request_info)
      !comment.reload.hidden?
    end

    fanout_workers { |_event| [Stream::Activities::CommentCreated] }
  end
end
