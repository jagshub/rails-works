# frozen_string_literal: true

module Maker::Feed::Activities
  extend self

  def call(days_ago:)
    day = days_ago.to_i.days.ago
    start_day = day.beginning_of_day
    end_day = day.end_of_day
    period = start_day..end_day

    scope = MakerActivity.feed.not_spam.where(created_at: period)
    scope = scope.reverse_chronological
    scope
  end
end
