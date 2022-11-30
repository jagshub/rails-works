# frozen_string_literal: true

class Cron::Spam::SimilarVotesWorker < ApplicationJob
  def perform
    Spam::Posts.run_all_checks
  end
end
