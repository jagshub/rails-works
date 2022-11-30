# frozen_string_literal: true

# Sends an email via ActionMailer.

module Notifications::Channels::Email::Service
  extend self

  def call(event)
    notification = event.notification
    notifier = notification.notifier
    notifier.mailer(notification).deliver_now
  end
end
