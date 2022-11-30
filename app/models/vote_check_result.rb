# frozen_string_literal: true

# == Schema Information
#
# Table name: vote_check_results
#
#  id              :integer          not null, primary key
#  vote_id         :integer          not null
#  check           :integer          not null
#  spam_score      :integer          default(0), not null
#  vote_ring_score :integer          default(0), not null
#
# Indexes
#
#  index_vote_check_results_on_vote_id_and_check  (vote_id,check) UNIQUE
#

class VoteCheckResult < ApplicationRecord
  belongs_to :vote

  enum check:
    {
      user_role: 0,
      user_too_young: 1,
      no_click_through: 2,
      ip_already_voted: 3,
      twitter_referer_already_voted: 4,
      similar_username: 5,
    }
end
