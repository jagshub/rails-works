# frozen_string_literal: true

module Graph::Mutations
  class ModerationDiscussionThreadReject < BaseMutation
    argument_record :discussion_thread, Discussion::Thread, required: true, authorize: :moderate

    returns Graph::Types::Discussion::ThreadType

    def perform(discussion_thread:)
      discussion_thread.update!(status: 'rejected')

      ModerationLog.create!(
        reference: discussion_thread,
        moderator: current_user,
        message: ModerationLog::REJECTED_THREAD,
      )
      discussion_thread
    end
  end
end
