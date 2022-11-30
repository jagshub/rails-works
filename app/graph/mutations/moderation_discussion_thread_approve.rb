# frozen_string_literal: true

module Graph::Mutations
  class ModerationDiscussionThreadApprove < BaseMutation
    argument_record :discussion_thread, Discussion::Thread, required: true, authorize: :moderate

    returns Graph::Types::Discussion::ThreadType

    def perform(discussion_thread:)
      ModerationLog.transaction do
        discussion_thread.update!(status: 'approved')

        ModerationLog.create!(
          reference: discussion_thread,
          moderator: current_user,
          message: ModerationLog::APPROVED_THREAD,
        )
      end

      discussion_thread
    end
  end
end
