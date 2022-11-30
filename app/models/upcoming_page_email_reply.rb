# frozen_string_literal: true

# == Schema Information
#
# Table name: upcoming_page_email_replies
#
#  id         :integer          not null, primary key
#  payload    :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UpcomingPageEmailReply < ApplicationRecord
  has_one :conversation_message, class_name: 'UpcomingPageConversationMessage', dependent: :nullify, inverse_of: :upcoming_page_email_reply

  scope :with_payload, ->(payload) { where('payload @> ?', payload.to_json) }

  scope :from_eq, ->(value) { with_payload('Sender' => value) }
  scope :to_eq, ->(value) { with_payload('Recipient' => value) }
  scope :custom_id_eq, ->(value) { with_payload('CustomID' => value) }
  scope :handled, -> { joins(:conversation_message) }
  scope :not_handled, -> { joins('LEFT OUTER JOIN upcoming_page_conversation_messages ON upcoming_page_email_reply_id = upcoming_page_email_replies.id').where('upcoming_page_conversation_messages.upcoming_page_email_reply_id' => nil) }

  class << self
    # NOTE(rstankov): Used for ActiveAdmin filtering menu
    def ransackable_scopes(_ = nil)
      %i(from_eq to_eq custom_id_eq)
    end

    def duplicate?(payload)
      return false if payload.nil? || payload['Headers'].nil? || payload['Headers']['Message-ID'].nil?

      where("payload->'Headers'->>'Message-ID' = ?", payload['Headers']['Message-ID']).exists?
    end
  end
end
