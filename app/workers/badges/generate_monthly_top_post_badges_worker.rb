# frozen_string_literal: true

class Badges::GenerateMonthlyTopPostBadgesWorker < ApplicationJob
  include ActiveJobHandleDeserializationError

  def perform(date)
    HandleRaceCondition.call do
      Badges.generate_top_post_monthly_rank(date)
    end
  end
end
