# frozen_string_literal: true

class Cron::Spam::UserChecksWorker < ApplicationJob
  def perform
    Spam::Posts.run_all_checks
  end
end
