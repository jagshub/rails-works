# frozen_string_literal: true

class Cron::Posts::StalePreLaunchedPostsWorker < ApplicationJob
  def perform
    threshold = 180.days.ago.to_date

    Post.pre_launch.where('scheduled_at < ?', threshold).find_each do |post|
      post.update!(product_state: Post.product_states[:default])
    end
  end
end
