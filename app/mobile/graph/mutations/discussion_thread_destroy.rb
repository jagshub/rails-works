# frozen_string_literal: true

module Mobile::Graph::Mutations
  class DiscussionThreadDestroy < BaseMutation
    argument_record :thread, ::Discussion::Thread, required: true, authorize: :destroy

    returns Mobile::Graph::Types::Discussion::ThreadType

    def perform(thread:)
      thread.destroy!
      thread
    end
  end
end
