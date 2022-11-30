# frozen_string_literal: true

class Badges::GenerateWeeklyTopPostTopicBadgesWorker < ApplicationJob
  include ActiveJobHandleDeserializationError

  queue_as :long_running

  def perform(date = Time.current.to_s)
    HandleRaceCondition.call do
      Badges.generate_top_post_topic_weekly_rank(date)
    end
  end
end
