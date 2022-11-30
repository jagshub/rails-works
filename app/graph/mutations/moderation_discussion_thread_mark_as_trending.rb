# frozen_string_literal: true

module Graph::Mutations
  class ModerationDiscussionThreadMarkAsTrending < BaseMutation
    argument_record :discussion_thread, Discussion::Thread, required: true, authorize: :moderate

    returns Graph::Types::Discussion::ThreadType

    def perform(discussion_thread:)
      discussion_thread.update!(trending_at: Time.current.to_date)
      discussion_thread
    end
  end
end
