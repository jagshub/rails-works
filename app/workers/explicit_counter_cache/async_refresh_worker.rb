# frozen_string_literal: true

class ExplicitCounterCache::AsyncRefreshWorker < ApplicationJob
  queue_as :counter_cache

  def perform(subject, counter_name)
    subject.public_send("refresh_#{ counter_name }")
  end
end
