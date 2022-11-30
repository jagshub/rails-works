# frozen_string_literal: true

class Cron::Emails::MissedProductsWorker < ApplicationJob
  queue_as :long_running
  MAX_USERS_ALLOWED = 1000 ## Note(Bharat): This number is chosen so that the call payload doesn't exceed 4MB limit/call.

  def perform
    # NOTE(JL): Get all users where today marks 14, 28, or 42 days since they've last logged in
    users = User.where(last_active_at: [
                         14.days.ago.all_day,
                         28.days.ago.all_day,
                         42.days.ago.all_day,
                       ])
    event_data = []
    batch_users = []

    users.each do |user|
      event = Iterable::LaunchesMissedEvents.call(user: user)
      user_data_fields = Iterable::DataTypes.get_user_data_fields(user)

      event_data << event if event[:dataFields][:post_items].any?
      batch_users << { email: user.email, dataFields: user_data_fields, userId: user.id.to_s }

      next unless event_data.length == MAX_USERS_ALLOWED

      External::IterableAPI.bulk_update(users: batch_users) # Some of the users may not be in the iterable
      Iterable.trigger_bulk_event(event_data)

      sleep 0.5 unless Rails.env.test? # Note(Bharat): this is to take care of rate limiting. only 5 req/sec are allowed.
      event_data = []
      batch_users = []
    end

    External::IterableAPI.bulk_update(users: batch_users) if batch_users.any?
    Iterable.trigger_bulk_event(event_data) if event_data.any?
  end
end
