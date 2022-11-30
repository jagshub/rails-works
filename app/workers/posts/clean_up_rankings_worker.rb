# frozen_string_literal: true

class Posts::CleanUpRankingsWorker < ApplicationJob
  def perform(post: nil)
    if post
      post.update!(daily_rank: nil, weekly_rank: nil, monthly_rank: nil)
    else
      Posts::RankingUpdater.nullify_unfeatured
    end
  end
end
