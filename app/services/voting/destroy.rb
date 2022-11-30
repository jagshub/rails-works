# frozen_string_literal: true

module Voting::Destroy
  extend self

  def call(subject:, user:)
    vote = Vote.find_by subject: subject, user: user
    return if vote.blank?

    destroy_vote(vote, subject)

    vote
  end

  private

  def destroy_vote(vote, subject)
    vote.destroy!
    subject.refresh_all_vote_counts
  end
end
