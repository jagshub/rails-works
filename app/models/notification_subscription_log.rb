# frozen_string_literal: true

# == Schema Information
#
# Table name: notification_subscription_logs
#
#  id              :integer          not null, primary key
#  subscriber_id   :integer          not null
#  kind            :integer          not null
#  channel_name    :string           not null
#  setting_details :string
#  source          :string           not null
#  source_details  :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_notification_subscription_logs_on_kind           (kind)
#  index_notification_subscription_logs_on_source         (source)
#  index_notification_subscription_logs_on_subscriber_id  (subscriber_id)
#

class NotificationSubscriptionLog < ApplicationRecord
  belongs_to :subscriber

  # Note(Mike Coutermarsh): We have id/type/kind in this model because we occasionally
  #   truncate the NotificationEvent/Log tables.
  validates :subscriber_id, :channel_name, :kind, presence: true

  enum kind: Notifications::Notifiers.enums

  validates :source_details, presence: true, if: proc { |log| log.source == 'promotion' }
end
