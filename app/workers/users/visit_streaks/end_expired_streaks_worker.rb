# frozen_string_literal: true

module Users::VisitStreaks
  class EndExpiredStreaksWorker < ApplicationJob
    def perform
      VisitStreak.where(ended_at: nil).where('last_visit_at   < ?', 48.hours.ago).update_all('ended_at = last_visit_at')
    end
  end
end
