# frozen_string_literal: true

# Note (TC): This worker will assess the progress of pending Gemologist badges
# that we have to track and toggle visibility on.
class UserBadges::Workers::GemologistProgressWorker < ApplicationJob
  include ActiveJobHandleDeserializationError
  queue_as :long_running

  def perform
    Badges::UserAwardBadge.with_data(identifier: 'gemologist', status: :in_progress).find_each do |badge|
      UserBadges::Badge::Gemologist.update_progress(badge: badge)
    end
  end
end
