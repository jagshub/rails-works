# frozen_string_literal: true

module Ships::Contacts::UnsubscribeSubscriber
  extend self

  def call(subscriber, source: nil)
    subscriber.update!(state: :unsubscribed, unsubscribe_source: source)
    # NOTE(rstankov): We assume when subscriber is unsubscribed from one upcoming page, no updates are wanted
    subscriber.contact.update!(unsubscribed_at: Time.current) unless subscriber.contact.unsubscribed_at
    UpcomingPages::ScheduleWebhook.user_unsubscribed(subscriber)
  end
end
