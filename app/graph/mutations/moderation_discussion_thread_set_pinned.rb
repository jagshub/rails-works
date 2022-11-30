# frozen_string_literal: true

module Graph::Mutations
  class ModerationDiscussionThreadSetPinned < BaseMutation
    argument_record :discussion_thread, Discussion::Thread, required: true, authorize: :moderate
    argument :pinned, Boolean, required: true

    returns Graph::Types::Discussion::ThreadType

    def perform(discussion_thread:, pinned:)
      discussion_thread.update!(pinned: pinned)
      discussion_thread
    end
  end
end
