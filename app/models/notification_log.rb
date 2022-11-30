# frozen_string_literal: true

# == Schema Information
#
# Table name: notification_logs
#
#  id              :integer          not null, primary key
#  created_at      :datetime         not null
#  kind            :integer          not null
#  notifyable_id   :integer          not null
#  notifyable_type :string           not null
#  subscriber_id   :integer          not null
#
# Indexes
#
#  idx_notification_logs_on_kind_and_notifyable_type_and_notify_id  (kind,notifyable_type,notifyable_id)
#  notification_logs_unique                                         (subscriber_id,kind,notifyable_id,notifyable_type) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (subscriber_id => notifications_subscribers.id)
#

class NotificationLog < ApplicationRecord
  belongs_to :subscriber
  belongs_to :notifyable, polymorphic: true

  has_many :events, class_name: 'NotificationEvent', foreign_key: 'notification_id', inverse_of: :notification, dependent: :delete_all

  validates :kind, presence: true

  enum kind: Notifications::Notifiers.enums

  def notifier
    @notifier ||= Notifications::Notifiers.for kind
  end

  def too_many_notifications?(channel)
    self.class.joins(:events)
        .where("notification_events.sent_at > NOW() - '? hours'::interval", minimum_hours_distance_for(channel))
        .where('notification_events.channel_name' => channel.channel_name)
        .where(subscriber: subscriber, kind: self.class.kinds[kind]).exists?
  end

  private

  def minimum_hours_distance_for(channel)
    (notifier.channels[channel.channel_name] || {})[:minimum_hours_distance] || channel.minimum_hours_distance
  end
end
