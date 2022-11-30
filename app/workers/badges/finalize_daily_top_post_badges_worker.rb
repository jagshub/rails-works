# frozen_string_literal: true

class Badges::FinalizeDailyTopPostBadgesWorker < ApplicationJob
  include ActiveJobHandleDeserializationError

  queue_as :long_running

  # Note(AR): Called to commit yesterday's badges based on their final daily
  # rank.
  def perform
    yesterday = 1.day.ago

    HandleRaceCondition.call do
      Posts::RankingUpdater.for_day(yesterday).call
      Badges.generate_top_post_daily_rank(yesterday)
    end
  end
end
