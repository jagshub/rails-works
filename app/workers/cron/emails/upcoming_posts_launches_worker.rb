# frozen_string_literal: true

class Cron::Emails::UpcomingPostsLaunchesWorker < ApplicationJob
  queue_as :long_running

  def perform
    within_last_hour = 1.hour.ago.beginning_of_hour..1.hour.ago.end_of_hour

    Upcoming::Event
      .joins(:post)
      .merge(Post.not_trashed)
      .where(posts: { scheduled_at: within_last_hour }).find_each do |upcoming_event|
        Rails.logger.info "Sending upcoming post launch email for #{ upcoming_event.id }"

        Notifications.notify_about(kind: 'upcoming_event_launch', object: upcoming_event)
      end
  end
end
