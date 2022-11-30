# frozen_string_literal: true

module Graph::Mutations
  class DiscussionThreadDestroy < BaseMutation
    argument_record :thread, ::Discussion::Thread, required: true, authorize: :destroy

    returns Graph::Types::Discussion::ThreadType

    def perform(thread:)
      thread.destroy!
      thread
    end
  end
end
