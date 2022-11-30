# frozen_string_literal: true

module Voting::PostVoteModeration
  extend self

  def mark_votes(user, **log)
    mark(user, log)
  end

  def unmark_votes(user, **log)
    mark(user, log, revert: true)
  end

  private

  def mark(user, log, revert: false)
    raise ArgumentError if log.empty?
    raise ArgumentError if !!revert != revert

    credible = revert

    ActiveRecord::Base.transaction do
      user.post_votes.where('credible=?', !credible).each do |vote|
        Spam.log_entity(
          entity: vote,
          user: user,
          action: revert == true ? :mark_as_credible : :mark_as_non_credible,
          kind: log[:kind],
          parent_log_id: log[:parent_log_id],
          level: log[:level],
          remarks: log[:remarks],
          current_user: log[:current_user],
        )
      end

      arguments = { credible: credible }
      arguments[:sandboxed] = false if revert

      user.post_votes.update_all arguments
      user.voted_posts.find_each(&:refresh_all_vote_counts)
    end
  end
end
