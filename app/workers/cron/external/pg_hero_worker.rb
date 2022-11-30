# frozen_string_literal: true

class Cron::External::PgHeroWorker < ApplicationJob
  def perform
    PgHero.capture_query_stats(verbose: true)
  end
end
