# frozen_string_literal: true

class Karma::RefreshPointsWorker < ApplicationJob
  def perform
    time_ago = [fetch_last_time || 1.hour.ago, 1.day.ago].min

    Karma::Users.ids_to_update_since(time_ago).each { |user_id| Karma::UpdateUserPointsWorker.perform_later(user_id) }

    save_run_time
  end

  private

  def fetch_last_time
    RedisConnect.current.get('karma_refresh_points_worker_ran_at')&.to_date
  end

  def save_run_time
    RedisConnect.current.set('karma_refresh_points_worker_ran_at', Time.zone.now)
  end
end
