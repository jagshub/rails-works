# frozen_string_literal: true

module Graph::Mutations
  class ModerationDiscussionThreadUnfeature < BaseMutation
    argument_record :discussion_thread, Discussion::Thread, required: true, authorize: :moderate

    returns Graph::Types::Discussion::ThreadType

    def perform(discussion_thread:)
      discussion_thread.update!(featured_at: nil)
      discussion_thread
    end
  end
end
