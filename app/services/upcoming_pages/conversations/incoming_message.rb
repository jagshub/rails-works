# frozen_string_literal: true

class UpcomingPages::Conversations::IncomingMessage
  attr_reader :reply, :delivery

  class << self
    def call(reply)
      new(reply).call
    end
  end

  def initialize(reply)
    @reply = reply
  end

  def call
    return if reply.conversation_message.present?

    @delivery = UpcomingPageMessageDelivery.find_by(id: custom_id)

    return if delivery.blank?

    if delivery.subject.is_a?(UpcomingPageConversationMessage)
      update_conversation
    elsif delivery.subject.is_a?(UpcomingPageMessage)
      create_conversation
    else
      raise "Invalid delivery subject - #{ delivery.subject_type }"
    end
  end

  private

  def update_conversation
    body = parse_body

    return if body.blank?

    conversation = delivery.subject.conversation

    UpcomingPageConversationMessage.transaction do
      create_conversation_message(
        conversation: conversation,
        subscriber: conversation.subscriber,
        upcoming_page_email_reply: reply,
        body: body,
      )

      conversation.update!(last_message_sent_at: Time.zone.now)
    end
  end

  def create_conversation
    upcoming_page = delivery.subject.upcoming_page

    subscriber = upcoming_page.subscribers.find_by_email(sender)

    return if subscriber.blank?

    body = parse_body

    return if body.blank?

    UpcomingPageConversationMessage.transaction do
      conversation = UpcomingPageConversation.create!(
        upcoming_page: upcoming_page,
        upcoming_page_message: delivery.subject,
        last_message_sent_at: Time.zone.now,
      )

      create_conversation_message(
        conversation: conversation,
        subscriber: subscriber,
        upcoming_page_email_reply: reply,
        body: body,
      )
    end
  end

  def create_conversation_message(attributes)
    message = UpcomingPageConversationMessage.create!(attributes)
    # TODO(Dhruv): Create notification for the new UpcomingPage message
    Notifications.notify_about kind: :ship_new_conversation_message, object: message
  end

  def custom_id
    payload['CustomID']
  end

  def sender
    payload['Sender']
  end

  def parse_body
    EmailReplyParser.parse_reply(text_part.presence || inline_attachement.presence || '')
  end

  def text_part
    payload['Text-part']
  end

  def inline_attachement
    return unless valid_base64?(payload['InlineAttachment1'])

    Base64.decode64(payload['InlineAttachment1'])
  end

  def valid_base64?(value)
    # NOTE(rstankov): Some random new lines are appearing when decoding attachments
    value.present? && value.delete("\n") == Base64.encode64(Base64.decode64(value)).delete("\n")
  end

  def payload
    reply.payload
  end
end
