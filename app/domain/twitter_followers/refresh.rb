# frozen_string_literal: true

class TwitterFollowers::Refresh < ApplicationJob
  include ActiveJobHandleNetworkErrors
  queue_as :default

  TWITTER_REQ_PERIOD = 17
  BATCH_SIZE = 900

  # Note(TC): Twitter /users/ API has a 900/15min request limit. This limit is per endpoint so
  # exhausting here will not cause downstream issues with any other Twitter API calls.
  # What we do is batch these requests with some room for Twitter API to replenish our call limits
  # and still be able to manage a large amount of calls spread out over time.
  def perform
    time_delay = 0

    scope.find_in_batches(batch_size: BATCH_SIZE) do |group|
      group.each do |record|
        TwitterFollowers::Sync.set(wait: time_delay.minutes).perform_later(subject: record.subject)
      end
      time_delay += TWITTER_REQ_PERIOD
    end
  end

  private

  def scope
    scope = TwitterFollowerCount
    TwitterFollowers::COOLDOWN.each_with_index do |settings, index|
      scope = if index.zero?
                scope.where('subject_type = ? AND last_checked <= ?', settings[0], settings[1].ago)
              else
                scope.or(TwitterFollowerCount.where('subject_type = ? AND last_checked <= ?', settings[0], settings[1].ago))
              end
    end
    scope
  end
end
