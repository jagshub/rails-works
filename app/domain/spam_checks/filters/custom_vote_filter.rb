# frozen_string_literal: true

module SpamChecks::Filters::CustomVoteFilter
  extend self

  SCORE_THRESHOLD = 100

  SCORES = {
    reject: SCORE_THRESHOLD,
    problematic: SCORE_THRESHOLD / 2,
    skip: 0,
  }.freeze

  CHECKS = %w(
    IpAlreadyVoted
    NoClickThrough
    SimilarUsername
    TwitterRefererAlreadyVoted
    UserRole
    UserTooYoung
  ).freeze

  PREFIX = '::SpamChecks::Filters::CustomVoteFilter::'

  def check(filter_input)
    raise ArgumentError unless filter_input.record.is_a? Vote

    checks_info = {
      total_spam_score: 0,
      total_vote_ring_score: 0,
      failed_checks: [],
    }

    CHECKS.each do |check|
      check_class = (PREFIX + check).constantize

      spam_score      = SCORES[check_class.spam_score(filter_input.record)] || 0
      vote_ring_score = SCORES[check_class.vote_ring_score(filter_input.record)] || 0

      checks_info[:total_spam_score] += spam_score
      checks_info[:total_vote_ring_score] += vote_ring_score
      checks_info[check] = { spam_score: spam_score, vote_ring_score: vote_ring_score }
      checks_info[:failed_checks].push(check) if spam_score > 0 || vote_ring_score > 0
    end

    spam = checks_info[:total_spam_score] >= SCORE_THRESHOLD || checks_info[:total_vote_ring_score] >= SCORE_THRESHOLD

    filter_input.result(
      is_spam: spam,
      checked_data: { checks_info: checks_info },
    )
  end

  def readable_check_data(rule_log)
    failed_checks = rule_log.checked_data.dig('checks_info', 'failed_checks').join(', ')

    "Failed #{ failed_checks } checks in CustomVoteFilter"
  end
end
