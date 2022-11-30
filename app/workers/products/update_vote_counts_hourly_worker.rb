# frozen_string_literal: true

class Products::UpdateVoteCountsHourlyWorker < ApplicationJob
  include ActiveJobHandlePostgresErrors

  def perform
    # Note(AR): The job is hourly, but we take 2 hours, just to be safe
    updated_post_votes = Vote.updated_after(2.hours.ago).where(subject_type: 'Post')
    target_products = Product.joins(:posts).where(posts: { id: updated_post_votes.select(:subject_id) })

    target_products.find_each(&:update_vote_counts)
  end
end
