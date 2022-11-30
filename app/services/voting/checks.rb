# frozen_string_literal: true

module Voting::Checks
  extend self

  SCORE_THRESHOLD = 100

  def run_all_checks(vote)
    checks_info = {
      total_spam_score: 0,
      total_vote_ring_score: 0,
      failed_checks: [],
    }

    checks.each do |check_class, enum_value, check|
      spam_score      = SCORES[check_class.spam_score(vote)] || 0
      vote_ring_score = SCORES[check_class.vote_ring_score(vote)] || 0

      HandleRaceCondition.call do
        result = vote.check_results.find_or_initialize_by(check: enum_value)
        result.update! spam_score: spam_score, vote_ring_score: vote_ring_score
      end

      checks_info[:total_spam_score] += spam_score
      checks_info[:total_vote_ring_score] += vote_ring_score
      checks_info[check] = { spam_score: spam_score, vote_ring_score: vote_ring_score }
      checks_info[:failed_checks].push(check) if spam_score > 0 || vote_ring_score > 0
    end

    result = perform_action(vote, checks_info)

    # Todo(Rahul): Unify this system to Spam Filter System
    SpamChecks.check_vote vote

    result
  end

  def spam_score(vote)
    vote.check_results.to_a.sum(&:spam_score)
  end

  def vote_ring_score(vote)
    vote.check_results.to_a.sum(&:vote_ring_score)
  end

  def explain_vote_ring_score(vote)
    checks = vote.check_results.reduce([]) do |acc, result|
      acc << "#{ result.vote_ring_score }(#{ result.check.to_s.titleize })" if result.vote_ring_score > 0
      acc
    end

    score = vote_ring_score(vote)

    if checks.empty?
      "Score: #{ score }"
    else
      "Score: #{ checks.join(' + ') } = #{ score }"
    end
  end

  def credible?(vote)
    spam_score(vote) < SCORE_THRESHOLD && vote_ring_score(vote) < SCORE_THRESHOLD
  end

  private

  SCORES = {
    reject: SCORE_THRESHOLD,
    problematic: SCORE_THRESHOLD / 2,
    skip: 0,
  }.freeze

  def checks
    VoteCheckResult.checks.map do |check, enum_value|
      [('::Voting::Checks::' + check.camelcase).safe_constantize, enum_value, check]
    end
  end

  def perform_action(vote, checks_info)
    if checks_info[:total_spam_score] >= SCORE_THRESHOLD
      Voting.mark_as_spam(
        vote,
        more_information: checks_info,
        remarks: "Vote is marked as non credible and sandboxed as it fails the following checks: #{ checks_info[:failed_checks].join(', ') }",
      )
    elsif checks_info[:total_vote_ring_score] >= SCORE_THRESHOLD
      Voting.mark_as_spam(
        vote,
        more_information: checks_info,
        sandboxed: vote.sandboxed,
        remarks: "Vote is marked as non credible as it fails the following checks: #{ checks_info[:failed_checks].join(', ') }",
      )
    end

    true
  end
end
