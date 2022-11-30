# frozen_string_literal: true

# Note (LukasFittl): Check if the current vote's IP has already
#   voted for the same post with a different user account.

module Voting::Checks::IpAlreadyVoted
  extend self

  MAX_ALLOWED_VOTES_PER_IP = 5

  # NOTE(LukasFittl): Ideally we would have to re-run checks for the other votes
  #   as well in case this test passes - right now this only marks the 5th and
  #   later votes as problematic.

  def spam_score(vote)
    :problematic if too_many_votes_from_ip?(vote)
  end

  def vote_ring_score(vote)
    :problematic if too_many_votes_from_ip?(vote)
  end

  def too_many_votes_from_ip?(vote)
    return if vote.vote_info.blank?

    voter_ip = vote.vote_info.request_ip
    return if voter_ip.blank?

    VoteInfo
      .where(request_ip: voter_ip.to_s).where.not(vote_id: vote.id)
      .joins(:vote).where(votes: { subject_type: vote.subject_type, subject_id: vote.subject_id })
      .count >= MAX_ALLOWED_VOTES_PER_IP
  end
end
