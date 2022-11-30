# frozen_string_literal: true

module Graph::Mutations
  class ModerationDiscussionThreadHide < BaseMutation
    argument_record :discussion_thread, Discussion::Thread, required: true, authorize: :moderate

    returns Graph::Types::Discussion::ThreadType

    def perform(discussion_thread:)
      discussion_thread.hide
      discussion_thread
    end
  end
end
