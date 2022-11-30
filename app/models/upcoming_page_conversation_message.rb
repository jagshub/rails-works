# frozen_string_literal: true

# == Schema Information
#
# Table name: upcoming_page_conversation_messages
#
#  id                            :integer          not null, primary key
#  body                          :text             not null
#  upcoming_page_conversation_id :integer          not null
#  upcoming_page_email_reply_id  :integer
#  upcoming_page_subscriber_id   :integer
#  user_id                       :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_u_p_conversation_messages_on_u_p_conversation_id  (upcoming_page_conversation_id)
#  index_u_p_conversation_messages_on_u_p_email_reply_id   (upcoming_page_email_reply_id)
#  index_u_p_conversation_messages_on_u_p_sub_id           (upcoming_page_subscriber_id)
#  index_upcoming_page_conversation_messages_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (upcoming_page_conversation_id => upcoming_page_conversations.id)
#  fk_rails_...  (upcoming_page_email_reply_id => upcoming_page_email_replies.id)
#  fk_rails_...  (upcoming_page_subscriber_id => upcoming_page_subscribers.id)
#  fk_rails_...  (user_id => users.id)
#

class UpcomingPageConversationMessage < ApplicationRecord
  belongs_to :conversation, class_name: 'UpcomingPageConversation', foreign_key: :upcoming_page_conversation_id, inverse_of: :messages
  belongs_to :upcoming_page_email_reply, optional: true, inverse_of: :conversation_message

  belongs_to :subscriber, class_name: 'UpcomingPageSubscriber', foreign_key: :upcoming_page_subscriber_id, inverse_of: :conversation_messages, optional: true
  belongs_to :user, optional: true

  has_one :delivery, class_name: 'UpcomingPageMessageDelivery', as: :subject, inverse_of: :subject, dependent: :destroy

  delegate :upcoming_page, :upcoming_page_message, to: :conversation
  delegate :name, to: :subscriber, prefix: true

  validates :body, presence: true
  validates :upcoming_page_email_reply_id, uniqueness: { allow_nil: true }

  scope :newest, -> { order(arel_table[:created_at].desc) }
  scope :by_date, -> { order(arel_table[:created_at].asc) }

  def mailjet_campaign
    "upcoming_page_conversation_message_#{ conversation.id }_#{ id }"
  end
end
