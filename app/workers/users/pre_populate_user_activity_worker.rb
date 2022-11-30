# frozen_string_literal: true

module Users
  class PrePopulateUserActivityWorker < ApplicationJob
    queue_as :data_migrations

    def perform(user)
      user.update! activity_events_count: 0 if user.activity_events_count.nil?
      user.reviews.find_each do |event|
        create_event(user, event)
      end
      user.discussion_threads.find_each do |event|
        create_event(user, event)
      end
      user.comments.find_each do |event|
        create_event(user, event)
      end
    end

    private

    def create_event(user, event)
      activity_event = user.activity_events.find_by(subject: event)
      return if activity_event.present?

      user.activity_events.create!(subject: event, occurred_at: event.created_at)
    end
  end
end
