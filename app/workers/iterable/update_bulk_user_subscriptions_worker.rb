# frozen_string_literal: true

class Iterable::UpdateBulkUserSubscriptionsWorker < ApplicationJob
  include ActiveJobHandleNetworkErrors
  queue_as :long_running

  MAX_USERS_ALLOWED = 1500 ## Note(Bharat): This number is chosen so that the call payload doesn't exceed 4MB limit/call.

  def perform
    end_date = Date.current
    start_date = Date.current - 18.months

    start_user_id = Redis.current.get('iterable:sync_bulk_user_subscriptions:last_user_synced_id').to_i
    start_user_id = 0 if start_user_id.blank?

    users = User.where('id > ?', start_user_id).where('last_active_at BETWEEN ? AND ?', start_date, end_date).not_trashed.order('id ASC')
    batch_users = []
    users.find_each do |user|
      next unless user.verified?

      message_types = Iterable::DataTypes.get_message_types(user)

      user_data = {
        email: user.email,
        userId: user.id.to_s,
        unsubscribedMessageTypeIds: message_types[:unsubscribed_message_type_ids],
        subscribedMessageTypeIds: message_types[:subscribed_message_type_ids],
      }

      batch_users.push(user_data)

      if batch_users.length == MAX_USERS_ALLOWED
        External::IterableAPI.bulk_update_subscriptions(users: batch_users)

        Redis.current.set('iterable:sync_bulk_user_subscriptions:last_user_synced_id', batch_users[-1][:userId])

        sleep 0.3 unless Rails.env.test? # Note(Bharat): this is to take care of rate limiting. only 5 req/sec are allowed.
        batch_users = []
      end
    end

    External::IterableAPI.bulk_update_subscriptions(users: batch_users) if batch_users.any?
  end
end
