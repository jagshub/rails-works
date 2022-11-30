# frozen_string_literal: true

# Note (TC): This badge awards the Top Post badge to all makers of a product that
# is in the top 5 of products for a given day. This is executed by `every_day_end` cron
# that executes at 4PM PST. A user can win many of these, but only one per post.
class UserBadges::Workers::TopProductWorker < ApplicationJob
  include ActiveJobHandleDeserializationError
  queue_as :default

  def perform
    Badges::TopPostBadge.with_data(date: Time.zone.now.to_date, period: 'daily').find_each do |badge|
      badge.subject.makers.each do |maker|
        UserBadges::Badge::TopProduct.update_or_create(
          data: { identifier: 'top_product', for_post_id: badge.subject_id, status: UserBadges::Badge::TopProduct::DEFAULT_STATUS },
          user: maker,
        )
      end
    end
  end
end
