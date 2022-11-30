# frozen_string_literal: true

# Note (LukasFittl): Reject votes by known spammers or company accounts.

module SpamChecks::Filters::CustomVoteFilter::UserRole
  extend self

  def spam_score(vote)
    :reject if Spam::User.spammer_user?(vote.user)
  end

  def vote_ring_score(vote)
    :reject unless Spam::User.credible_role?(vote.user)
  end
end
