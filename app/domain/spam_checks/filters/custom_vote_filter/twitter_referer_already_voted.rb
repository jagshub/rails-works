# frozen_string_literal: true

# Note (LukasFittl): This is an experimental check to work with referer data
#   to find vote rings using Twitter to ask for votes.

module SpamChecks::Filters::CustomVoteFilter::TwitterRefererAlreadyVoted
  extend self

  MAX_ALLOWED_VOTES_PER_REFERER = 5

  def spam_score(_vote)
    :skip
  end

  # NOTE(LukasFittl): Ideally we would have to re-run checks for the other votes
  #   as well in case this test passes - right now this only marks the 5th and
  #   later votes as problematic.
  def vote_ring_score(vote)
    return if vote.vote_info.blank?

    referer = vote.vote_info.first_referer
    return unless referer.present? && referer.starts_with?('t.co/')

    :problematic if referer_already_voted?(referer, vote)
  end

  def referer_already_voted?(referer, vote)
    VoteInfo
      .where(first_referer: referer).where('visit_duration < 60').where.not(vote_id: vote.id)
      .joins(:vote).where(votes: { subject_type: vote.subject_type, subject_id: vote.subject_id })
      .count >= MAX_ALLOWED_VOTES_PER_REFERER
  end
end
