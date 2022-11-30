# frozen_string_literal: true

class UpcomingPageMessageMailer < ApplicationMailer
  include Ships::MailWithShipApiKeys
  def status_update(upcoming_page_message:, to:, token:, body:, test: false, custom_id: nil)
    @upcoming_page = upcoming_page_message.upcoming_page
    @message = upcoming_page_message
    @user = @message.author
    @token = token
    @body = body

    unless test
      email_campaign_name(@message.mailjet_campaign, deduplicate: true)
      email_custom_id custom_id
    end

    mail(
      to: to,
      from: from_for_page(@upcoming_page),
      subject: test ? "TEST: #{ @message.subject }" : @message.subject,
    )
  end

  def conversation(delivery)
    @conversation_message = delivery.subject
    @user = @conversation_message.user
    @upcoming_page = @conversation_message.upcoming_page
    @token = delivery.subscriber.token

    email_campaign_name(@conversation_message.mailjet_campaign, deduplicate: true)
    email_custom_id delivery.id

    mail(
      to: delivery.subscriber.email,
      from: from_for_page(@upcoming_page),
      subject: "#{ @user.name } has sent you a message",
    )
  end

  private

  def from_for_page(upcoming_page)
    name = @user.name || "@#{ @user.username }"
    %("#{ name }" <#{ upcoming_page.inbox_email }>)
  end
end
