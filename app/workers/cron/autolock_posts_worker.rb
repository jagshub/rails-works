# frozen_string_literal: true

class Cron::AutolockPostsWorker < ApplicationJob
  def perform
    Post.where(locked: false).where('scheduled_at < ?', 1.month.ago).update_all(locked: true)
  end
end
