# frozen_string_literal: true

module Spam::Users
  extend self

  CHECKS = [::Spam::Posts::Checks::SimilarVotes].freeze
  CHECK_NAME = 'Check: User Spam'

  def run_all_checks
    results = Spam::Checks.run_all(CHECKS)
    Spam::Checks.perform_action(results, current_user: CHECK_NAME)
  end
end
