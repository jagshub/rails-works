# frozen_string_literal: true

class Cron::Emails::NudgeLaunchWorker < ApplicationJob
  queue_as :long_running

  LOOKBACK_PERIOD = 7.months
  RANK_CUTOFF = 10

  # NOTE(DZ): This job looks up featured posts launched LOOKBACK_PERIOD ago that
  # achieved a rank of at least RANK_CUTOFF. If this post is the latest launch
  # of a product, it will send a nudge email to the makers.
  def perform
    eligible_posts =
      Post
      .where_date_eq(:featured_at, LOOKBACK_PERIOD.ago.to_date)
      .where(Post.arel_table[:daily_rank].lteq(RANK_CUTOFF))
      .not_trashed

    eligible_posts.each do |post|
      product = post.new_product
      next if product.blank?
      next unless product.posts.visible.by_created_at.first.id == post.id

      post.makers.each do |maker|
        ProductMailer.nudge_launch(maker, product, post).deliver_now
      end
    end
  end
end
