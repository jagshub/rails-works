# frozen_string_literal: true

module Graph::Mutations
  class ModerationDiscussionThreadUnhide < BaseMutation
    argument_record :discussion_thread, Discussion::Thread, required: true, authorize: :moderate

    returns Graph::Types::Discussion::ThreadType

    def perform(discussion_thread:)
      discussion_thread.show
      discussion_thread
    end
  end
end
