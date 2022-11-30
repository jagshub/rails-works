# frozen_string_literal: true

# == Schema Information
#
# Table name: notification_push_logs
#
#  id                    :bigint(8)        not null, primary key
#  uuid                  :string           not null
#  channel               :string           not null
#  kind                  :string           not null
#  received              :boolean          default(FALSE)
#  converted             :boolean          default(FALSE)
#  url                   :string
#  platform              :string           not null
#  delivery_method       :string           not null
#  sent_at               :datetime         not null
#  raw_response          :jsonb            not null
#  user_id               :integer
#  notification_event_id :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_notification_push_logs_on_uuid  (uuid) UNIQUE
#
class NotificationPushLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :subscriber, optional: true
  validate :ensure_valid_kind
  validate :ensure_valid_channel
  validate :ensure_valid_delivery_methods

  # https://documentation.onesignal.com/reference/view-notifications
  API_TYPES = {
    dashboard: 0,
    api: 1,
    automated: 3,
  }.freeze
  DEFAULT_API_TYPE = API_TYPES[:api]
  HOURLY_SYNC_WINDOW = 72

  enum kinds: Notifications::Notifiers.enums.keys.append(:unknown_kind)
  enum channels: Notifications::Channels::CHANNELS.keys.append(:unknown_channel)
  enum delivery_methods: ['immediate', 'last-active']

  private

  def ensure_valid_kind
    errors.add :kind, :invalid if NotificationPushLog.kinds[kind&.to_sym].blank?
  end

  def ensure_valid_channel
    errors.add :channel, :invalid if NotificationPushLog.channels[channel&.to_sym].blank?
  end

  def ensure_valid_delivery_methods
    errors.add :delivery_method, :invalid if NotificationPushLog.delivery_methods[delivery_method&.to_sym].blank?
  end
end
