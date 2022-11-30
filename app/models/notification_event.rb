# frozen_string_literal: true

# == Schema Information
#
# Table name: notification_events
#
#  id              :integer          not null, primary key
#  notification_id :integer          not null
#  channel_name    :string           not null
#  status          :integer          default("pending"), not null
#  failure_reason  :text
#  sent_at         :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  interacted_at   :datetime
#
# Indexes
#
#  index_notification_events_on_notification_id_and_channel_name  (notification_id,channel_name)
#
# Foreign Keys
#
#  fk_rails_...  (notification_id => notification_logs.id)
#

class NotificationEvent < ApplicationRecord
  belongs_to :notification, class_name: 'NotificationLog'

  validates :status, presence: true

  enum status: {
    pending: 0,
    rejected: 1,
    postponed: 2,
    sent: 3,
    failed: 4,
  }

  delegate :kind, :notifier, :notifyable, :subscriber, to: :notification
  delegate :user, to: :subscriber

  def channel
    @channel ||= Notifications::Channels[channel_name]
  end

  def mark_as_rejected
    self.status = :rejected
  end

  def mark_as_postponed
    self.status = :postponed
  end

  def mark_as_sent
    self.status = :sent
    self.sent_at = Time.current
  end

  def mark_as_failed(reason:)
    self.status = :failed
    self.failure_reason = reason
  end

  def too_many_notifications?
    notification.too_many_notifications? channel
  end
end
