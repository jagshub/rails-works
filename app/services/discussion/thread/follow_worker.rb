# frozen_string_literal: true

class Discussion::Thread::FollowWorker < ApplicationJob
  include ActiveJobHandleDeserializationError

  def perform(thread)
    Discussion::Thread::Follow.call(thread: thread, user: thread.user)
  end
end
