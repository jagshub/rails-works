# frozen_string_literal: true

class Iterable::SyncUserSubscriptionWorker < ApplicationJob
  include ActiveJobHandleNetworkErrors

  def perform(user)
    return unless user.verified? && user.email.present?

    message_types = Iterable::DataTypes.get_message_types(user)

    External::IterableAPI.update_user_subscriptions(email: user.email, user_id: user.id.to_s, unsubscribed_message_type_ids: message_types[:unsubscribed_message_type_ids], subscribed_message_type_ids: message_types[:subscribed_message_type_ids])
  end
end
