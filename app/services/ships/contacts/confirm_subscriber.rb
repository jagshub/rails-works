# frozen_string_literal: true

module Ships::Contacts::ConfirmSubscriber
  extend self

  def call(subscription_target:, token:)
    contact = subscription_target.account.contacts.find_by! token: token
    contact.user ||= User.find_by_email(contact.email)
    contact.email_confirmed = true
    contact.save!

    subscriber = contact.subscribers.find_or_initialize_by upcoming_page_id: subscription_target.id
    subscriber.state = :confirmed
    subscriber.save!

    UpcomingPages::ScheduleWebhook.user_subscribed(subscriber)
    Notifications.notify_about(kind: :ship_new_subscriber, object: subscriber)

    subscriber
  end
end
