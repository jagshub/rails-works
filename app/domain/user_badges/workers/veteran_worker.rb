# frozen_string_literal: true

# Note (TC): This badge is awarded only once to a credible user whose account
# age is over the limit and has not already received this badge.
class UserBadges::Workers::VeteranWorker < ApplicationJob
  include ActiveJobHandleDeserializationError
  queue_as :long_running

  BADGE_IDENTIFIER = 'veteran'
  JOIN_QUERY = <<-SQL
    LEFT JOIN badges on users.id::int = badges.subject_id::int
    AND badges.subject_type = 'User'
    AND badges.data->>'identifier' = 'veteran'
  SQL

  def perform
    User.credible.where_time_lteq(:created_at, UserBadges::Badge::Veteran::MIN_YEARS.ago)
        .joins(JOIN_QUERY).where('badges.subject_id IS NULL').find_each do |user|
      UserBadges::Badge::Veteran.update_or_create(
        data: { identifier: BADGE_IDENTIFIER, status: UserBadges::Badge::TopProduct::DEFAULT_STATUS },
        user: user,
      )
    end
  end
end
