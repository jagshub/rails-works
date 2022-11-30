# frozen_string_literal: true

class Posts::UpdateCurrentDailyRankingWorker < ApplicationJob
  include ActiveJobHandlePostgresErrors

  def perform
    current_time = Time.current

    Posts::RankingUpdater.for_day(current_time).call

    HandleRaceCondition.call do
      Badges.generate_top_post_daily_rank(current_time)
    end
  end
end
