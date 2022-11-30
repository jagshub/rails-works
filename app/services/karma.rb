# frozen_string_literal: true

module Karma
  extend self

  def badge_for_user(user)
    Karma::Badge.for(user)
  end

  def calculate_points_for_user(user)
    Karma::Points.for(user)
  end

  def points_for_user(user)
    user.spammer? ? 0 : user.karma_points.to_i
  end

  def update_points_for_user(user)
    Karma::Points.update_for(user)
  end

  def refresh_points_worker
    Karma::RefreshPointsWorker
  end

  def min_credible_karama
    10
  end
end
