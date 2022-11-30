# frozen_string_literal: true

# Note(Rahul): Check README for more info:
#   https://github.com/producthunt/producthunt/blob/master/app/domain/ab_test/README.md

module AbTest
  extend self

  # NOTE(rstankov): Currently running AB tests with their possible options
  # (results can be seen at `/admin/split`)
  # example: { 'test_name' => %w(control variant2 variant3) }
  #
  # To enable feature flag, add flag in flipper w/ naming pattern:
  #  "ab_<split_test_name>"
  TESTS = {
    'mobile_test' => ['control', 'test1', 'test2'],
    'mobile_discovery_tabbar_icon' => %w(magnifier compass),
    'mobile_discussion_share_button_position' => %w(menu toolbar),
  }.freeze

  def variant_for(test:, ctx:)
    from_graphql_context(ctx).value_for(test)
  end

  # NOTE(rstankov): What `reset` does?
  #   `true`  - resets the A/B Test for a user, next time they come will see other variant
  #   `false` - next time they come will see the same variant as completed one
  #   More info: https://github.com/splitrb/split#reset-after-completion
  def finish_test_for_participant(test:, ctx:, reset: false)
    from_graphql_context(ctx).ab_finished(test, reset: reset)
  end

  def active_tests_for(ctx:)
    from_graphql_context(ctx).ab_user.active_experiments.map do |(name, variant)|
      AbTest::TestVariant.new(name, variant)
    end
  end

  private

  def from_graphql_context(ctx)
    ::AbTest::Split.from_graphql_context(ctx)
  end
end

# NOTE(rstankov): For some reason Sidekiq doesnt want to load those
#   Loading manually
require_relative '../workers/ab_test/participant_log_worker'
require_relative '../workers/ab_test/mark_test_completed_worker'
