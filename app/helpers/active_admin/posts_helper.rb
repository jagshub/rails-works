# frozen_string_literal: true

module ActiveAdmin::PostsHelper
  def vote_check_vote_ring_score(vote, check)
    # Note (LukasFittl): We intentionally don't use a find_by here in order to avoid
    #   an N+1 query.
    check = vote.check_results.to_a.find { |r| r.check == check }
    return '-' if check.blank?

    check.vote_ring_score
  end
end
