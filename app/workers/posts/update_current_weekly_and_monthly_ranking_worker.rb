# frozen_string_literal: true

class Posts::UpdateCurrentWeeklyAndMonthlyRankingWorker < ApplicationJob
  include ActiveJobHandlePostgresErrors

  def perform
    current_time = Time.current

    Posts::RankingUpdater.for_week(current_time).call
    Posts::RankingUpdater.for_month(current_time).call
  end
end
