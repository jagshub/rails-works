# frozen_string_literal: true

# == Schema Information
#
# Table name: upcoming_page_conversations
#
#  id                       :integer          not null, primary key
#  upcoming_page_message_id :integer          not null
#  upcoming_page_id         :integer          not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  seen_at                  :datetime
#  last_message_sent_at     :datetime
#  trashed_at               :datetime
#
# Indexes
#
#  index_upcoming_page_conversations_on_trashed_at                (trashed_at)
#  index_upcoming_page_conversations_on_upcoming_page_id          (upcoming_page_id)
#  index_upcoming_page_conversations_on_upcoming_page_message_id  (upcoming_page_message_id)
#
# Foreign Keys
#
#  fk_rails_...  (upcoming_page_id => upcoming_pages.id)
#  fk_rails_...  (upcoming_page_message_id => upcoming_page_messages.id)
#

class UpcomingPageConversation < ApplicationRecord
  include Trashable

  belongs_to :upcoming_page, optional: false
  belongs_to :upcoming_page_message, optional: false

  has_many :messages, class_name: 'UpcomingPageConversationMessage', dependent: :delete_all, inverse_of: :conversation

  has_one :first_subscriber_message, -> { newest }, class_name: 'UpcomingPageConversationMessage', inverse_of: :conversation

  scope :unseen, -> { not_trashed.where(seen_at: nil).or(where(arel_table[:last_message_sent_at].gt(arel_table[:seen_at]))) }
  scope :by_date, -> { order(arel_table[:last_message_sent_at].desc) }

  delegate :subscriber, to: :last_subscriber_message

  def body
    messages.newest.first&.body
  end

  def seen?
    return false if seen_at.blank?
    return false if last_message_sent_at.blank?

    seen_at > last_message_sent_at
  end

  private

  def last_subscriber_message
    messages.where.not(upcoming_page_subscriber_id: nil).newest.first
  end
end
