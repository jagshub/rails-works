# frozen_string_literal: true

# == Schema Information
#
# Table name: upcoming_page_message_deliveries
#
#  id                          :integer          not null, primary key
#  upcoming_page_message_id    :integer
#  upcoming_page_subscriber_id :integer          not null
#  sent_at                     :datetime
#  opened_at                   :datetime
#  clicked_at                  :datetime
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  failed_at                   :datetime
#  subject_id                  :integer
#  subject_type                :string
#
# Indexes
#
#  index_u_p_m_deliveries_on_subject_and_subscriber              (subject_type,subject_id,upcoming_page_subscriber_id)
#  index_upcoming_page_message_deliveries_on_message_subscriber  (upcoming_page_message_id,upcoming_page_subscriber_id) UNIQUE
#  index_upcoming_page_message_deliveries_on_subscriber_id       (upcoming_page_subscriber_id)
#
# Foreign Keys
#
#  fk_rails_...  (upcoming_page_message_id => upcoming_page_messages.id)
#  fk_rails_...  (upcoming_page_subscriber_id => upcoming_page_subscribers.id)
#

class UpcomingPageMessageDelivery < ApplicationRecord
  # TODO(vesln): remove message
  belongs_to :message, class_name: 'UpcomingPageMessage', foreign_key: :upcoming_page_message_id, optional: true
  belongs_to :subscriber, class_name: 'UpcomingPageSubscriber', foreign_key: :upcoming_page_subscriber_id

  belongs_to :subject, polymorphic: true, optional: true

  validates :upcoming_page_subscriber_id, uniqueness: { scope: :upcoming_page_message_id }

  delegate :mailjet_campaign, to: :subject

  scope :sent, -> { where.not(sent_at: nil) }
  scope :opened, -> { where.not(opened_at: nil) }
  scope :clicked, -> { where.not(clicked_at: nil) }
  scope :failed, -> { where.not(failed_at: nil) }

  scope :by_sent, -> { order(arel_table[:sent_at].desc) }
  scope :by_opened, -> { order(arel_table[:opened_at].desc) }
  scope :by_clicked, -> { order(arel_table[:clicked_at].desc) }
  scope :by_failed, -> { order(arel_table[:failed_at].desc) }
  scope :from_message, -> { where(subject_type: UpcomingPageMessage.name) }

  after_commit :refresh_message_counters
  after_destroy :refresh_message_counters

  def refresh_message_counters
    subject.refresh_sent_count if subject.respond_to? :refresh_sent_count
    subject.refresh_opened_count if subject.respond_to? :refresh_opened_count
    subject.refresh_clicked_count if subject.respond_to? :refresh_clicked_count
    subject.refresh_failed_count if subject.respond_to? :refresh_failed_count
  end
end
