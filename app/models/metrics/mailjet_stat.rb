# frozen_string_literal: true

# == Schema Information
#
# Table name: mailjet_stats
#
#  id                             :bigint(8)        not null, primary key
#  campaign_id                    :string           not null
#  campaign_name                  :string           not null
#  date                           :date             not null
#  event_click_delay              :integer          default(0), not null
#  event_clicked_count            :integer          default(0), not null
#  event_open_delay               :integer          default(0), not null
#  event_opened_count             :integer          default(0), not null
#  event_spam_count               :integer          default(0), not null
#  event_unsubscribed_count       :integer          default(0), not null
#  event_workflow_exited_count    :integer          default(0), not null
#  message_blocked_count          :integer          default(0), not null
#  message_clicked_count          :integer          default(0), not null
#  message_deferred_count         :integer          default(0), not null
#  message_hard_bounced_count     :integer          default(0), not null
#  message_opened_count           :integer          default(0), not null
#  message_queued_count           :integer          default(0), not null
#  message_sent_count             :integer          default(0), not null
#  message_soft_bounced_count     :integer          default(0), not null
#  message_spam_count             :integer          default(0), not null
#  message_unsubscribed_count     :integer          default(0), not null
#  message_work_flow_exited_count :integer          default(0), not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#
# Indexes
#
#  index_mailjet_stats_on_campaign_id_and_date  (campaign_id,date) UNIQUE
#

class Metrics::MailjetStat < ApplicationRecord
  class << self
    STATCOUNTER_ATTRIBUTES = %i(
      event_click_delay
      event_clicked_count
      event_open_delay
      event_opened_count
      event_spam_count
      event_unsubscribed_count
      event_workflow_exited_count
      message_blocked_count
      message_clicked_count
      message_deferred_count
      message_hard_bounced_count
      message_opened_count
      message_queued_count
      message_sent_count
      message_soft_bounced_count
      message_spam_count
      message_unsubscribed_count
      message_work_flow_exited_count
    ).freeze

    def find_or_create_by_statcounters!(stat, campaign_name)
      record = find_or_initialize_by(
        campaign_id: stat.source_id,
        date: stat.timeslice.to_date,
      )
      record.campaign_name = campaign_name
      record.assign_attributes(stat.attributes.slice(*STATCOUNTER_ATTRIBUTES))
      record.save!
    end
  end
end
