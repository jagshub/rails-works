# frozen_string_literal: true

module Spam::Posts
  extend self

  CHECKS = [::Spam::Posts::Checks::SimilarVotes].freeze
  CHECK_NAME = 'Check: Post Spam'
  PERIOD = 2.days

  def run_all_checks(posts = nil, current_user: CHECK_NAME, kind: :automatic)
    posts ||= Post.visible.where('scheduled_at >= ?', Time.zone.now - PERIOD).all
    results = Spam::Checks.run_all(CHECKS, posts: posts)

    Spam::Checks.perform_action(results, current_user: current_user, kind: kind)
  end

  def run_sibling_users_check(at = Time.zone.now, current_user: CHECK_NAME, kind: :automatic)
    results = Spam::Checks.run_all([Spam::Posts::Checks::SiblingUsers], at: at)

    Spam::Checks.perform_action(results, current_user: current_user, kind: kind)
  end
end
