# frozen_string_literal: true

class Badges::GenerateWeeklyTopPostBadgesWorker < ApplicationJob
  include ActiveJobHandleDeserializationError

  def perform(date)
    HandleRaceCondition.call do
      Badges.generate_top_post_weekly_rank(date)
    end
  end
end
