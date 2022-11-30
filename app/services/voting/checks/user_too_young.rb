# frozen_string_literal: true

# Note(LukasFittl): Simple check that guards against votes by freshly registered
#   accounts - this also acts as a safety net against new aggressive spammers.

module Voting::Checks::UserTooYoung
  extend self

  def spam_score(_vote)
    :skip
  end

  def vote_ring_score(vote)
    :reject if voter_too_young?(vote)
  end

  def voter_too_young?(vote)
    vote.user.created_at > (vote.created_at - 24.hours)
  end
end
