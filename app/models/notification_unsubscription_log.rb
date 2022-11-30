# frozen_string_literal: true

# == Schema Information
#
# Table name: notification_unsubscription_logs
#
#  id              :integer          not null, primary key
#  subscriber_id   :integer          not null
#  kind            :integer          not null
#  channel_name    :string           not null
#  notifyable_id   :integer
#  notifyable_type :string
#  source          :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  source_details  :string
#
# Indexes
#
#  index_notification_unsubscription_logs_on_subscriber_id  (subscriber_id) WHERE ((notifyable_id IS NULL) AND (notifyable_type IS NULL))
#  notification_unsubscription_logs_unique                  (notifyable_type,notifyable_id,kind,channel_name,subscriber_id) UNIQUE WHERE ((notifyable_id IS NOT NULL) AND (notifyable_type IS NOT NULL))
#

class NotificationUnsubscriptionLog < ApplicationRecord
  belongs_to :subscriber
  belongs_to :notifyable, polymorphic: true, optional: true

  # Note(Mike Coutermarsh): We have id/type/kind in this model because we occasionally
  #   truncate the NotificationEvent/Log tables.
  validates :subscriber_id, :channel_name, :kind, presence: true

  enum kind: Notifications::Notifiers.enums
  enum source: { unsubscribe_link: 0,
                 user_settings: 1,
                 admin: 2,
                 unknown: 3,
                 email_bounced: 4,
                 email_client_unsubscribe: 5,
                 newsletter_list_cleaning: 6 }

  validates :source_details, presence: true, if: :newsletter_list_cleaning?

  def self.create_from_notification!(notification, source:)
    return if notification.blank?

    create!(subscriber: notification.subscriber,
            notifyable: notification.notifyable,
            channel_name: notification.channel_name,
            kind: notification.kind,
            source: source)
  rescue ActiveRecord::RecordNotUnique
    # Note(Mike Coutermarsh): If a user hits an unsubscribe link multiple times for the same notification, we'll only record it once.
    nil
  end
end
