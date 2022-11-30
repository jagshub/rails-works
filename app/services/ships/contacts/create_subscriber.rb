# frozen_string_literal: true

class Ships::Contacts::CreateSubscriber
  class << self
    def from_import(subscription_target:, email:)
      new(
        subscription_target: subscription_target,
        email: email,
        origin: :from_import,
        auto_confirm: true,
        source_kind: 'import',
        imported: true,
      ).call
    end

    def from_subscription(
      subscription_target:,
      email: nil,
      user: nil,
      source_kind: nil,
      source_reference_id: nil,
      os: nil,
      device_type: nil,
      ip_address: nil,
      user_agent: nil
    )
      new(
        subscription_target: subscription_target,
        email: email || user&.email,
        user: user,
        origin: :from_subscription,
        auto_confirm: false,
        source_kind: source_kind,
        source_reference_id: source_reference_id,
        os: os,
        device_type: device_type,
        ip_address: ip_address,
        user_agent: user_agent,
      ).call
    end
  end

  attr_reader :subscription_target, :email, :subscription_attributess, :contact_attributes, :user

  SUBSCRIPTION_ATTRIBUTES = %i(
    source_kind
    source_reference_id
  ).freeze

  CONTACT_ATTRIBUTES = %i(
    origin
    os
    device_type
    ip_address
    user_agent
  ).freeze

  def initialize(subscription_target:, email:, user: nil, auto_confirm: false, **other_attributes)
    @subscription_target = subscription_target
    @email = EmailValidator.normalize(email)
    @user = user
    @auto_confirm = auto_confirm
    @subscription_attributess = other_attributes.slice(*SUBSCRIPTION_ATTRIBUTES)
    @contact_attributes = other_attributes.slice(*CONTACT_ATTRIBUTES)
  end

  def call
    contact = find_or_create_contact

    return errors_from(contact) if contact.new_record?

    subscriber = find_or_create_subscriber_with contact

    return errors_from(subscriber) if subscriber.new_record?

    schedule_workers contact, subscriber

    subscriber
  end

  private

  def errors_from(record)
    OpenStruct.new(errors: record.errors)
  end

  def auto_confirm?
    @auto_confirm
  end

  def find_or_create_contact
    HandleRaceCondition.call do
      contact = subscription_target.account.contacts_with_trashed.find_by user_id: user.id if user
      contact ||= subscription_target.account.contacts_with_trashed.find_or_initialize_by email: email
      contact.user ||= user || User.find_by_email(contact.email)
      contact.clearbit_person_profile ||= Clearbit::PersonProfile.find_by(email: contact.email)
      contact.email_confirmed = contact_email_confirmed?(contact)
      contact.assign_attributes contact_attributes
      contact.unsubscribed_at = nil
      contact.trashed_at = nil
      contact.save
      contact
    end
  end

  def contact_email_confirmed?(contact)
    return true if auto_confirm?
    return true if contact.email_confirmed?
    return true if contact.user.present?
    return true if contact.clearbit_person_profile.present?
    return true if ShipContact.with_confirmed_email.where(email: contact.email).exists?

    false
  end

  def find_or_create_subscriber_with(contact)
    HandleRaceCondition.call do
      subscriber = subscription_target.subscribers.find_or_initialize_by ship_contact_id: contact.id
      subscriber.state = contact.email_confirmed? ? :confirmed : :pending
      subscriber.token = contact.token
      subscriber.assign_attributes(subscription_attributess)
      subscriber.save
      subscriber
    end
  end

  def schedule_workers(contact, subscriber)
    if contact.from_import?
      UpcomingPages::EnrichmentWorker.perform_later(subscriber)
    else
      if subscriber.confirmed?
        UpcomingPages::ScheduleWebhook.user_subscribed(subscriber)
        Notifications.notify_about(kind: :ship_new_subscriber, object: subscriber)
      else
        UpcomingPageSubscriberConfirmationMailerWorker.perform_later(subscriber)
      end

      UpcomingPages::EnrichmentWorker.perform_later(subscriber)

      Stream::Events::UpcomingPageSubscriberCreated.trigger(
        user: user,
        subject: subscriber,
        source: :web,
        request_info: contact.slice(:os, :device_type, :user_agent, :ip_address),
        payload: { subscription_origin: contact.origin },
      )
    end
  end
end
