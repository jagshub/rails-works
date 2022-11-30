# frozen_string_literal: true

class Karma::UpdateUserPointsWorker < ApplicationJob
  def perform(user_id)
    # NOTE (emilov): sometimes user_id appears to be empty so the find() below barfs
    return if user_id.blank?

    Karma.update_points_for_user(User.find(user_id))
  end
end
