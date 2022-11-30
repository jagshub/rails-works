# frozen_string_literal: true

module UpcomingPages::ScheduleWebhook
  extend self

  def user_subscribed(subscriber)
    call(subscriber, 'user.subscribed')
  end

  def user_unsubscribed(subscriber)
    call(subscriber, 'user.unsubscribed')
  end

  private

  def call(subscriber, event)
    return unless subscriber.upcoming_page.webhook_url?

    UpcomingPages::WebhookWorker.perform_later(subscriber, event)
  end
end
