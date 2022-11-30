# frozen_string_literal: true

module Spam
  extend self

  LEVELS = {
    'questionable' => Spam::MarkQuestionableEntity,
    'inappropriate' => Spam::MarkInappropriateEntity,
    'spammer' => Spam::MarkSpammerEntity,
    'harmful' => Spam::MarkHarmfulEntity,
  }.freeze

  def mark(level:, **args)
    LEVELS.fetch(level).call(args)
  end

  def log_entity(**args)
    Spam::LogEntity.call(args)
  end

  def mark_entity(**args)
    Spam::MarkEntity.call(args)
  end

  def mark_votes_as_spam(vote_ids:, current_user:)
    Vote.where(id: vote_ids).find_each do |vote|
      Spam::MarkVoteAsSpam.call(
        vote: vote,
        current_user: current_user,
        remarks: 'Bulk action perform from admin.',
      )
    end
  end
end
