# frozen_string_literal: true

# NOTE(rstankov) Jobs are created from our webhooks app using the Sidekiq
# message format.
#
# The Sidekiq message format is different than the ActiveJob message format,
# and is way less complex. Make sure to include `Sidekiq::Worker` and not
# class `ActiveJob::Base`.
#
# In case we want to switch to the AJ message format we can look how Sidekiq
# does this internally: https://github.com/rails/rails/blob/master/activejob/lib/active_job/arguments.rb
#
# If you change the class make sure to change it in the webhooks app as well:
# https://github.com/producthunt/webhooks/blob/master/lib/constants.js
#
# Documentation https://dev.mailjet.com/email-api/v3/eventcallbackurl/
#               https://dev.mailjet.com/guides/#events

class WebHooks::ShipEmailEventWorker
  include Sidekiq::Worker

  PROVIDER = 'mailjet'
  ERRORS = ['user unknown', 'mailbox inactive', 'invalid domain', 'no mail host'].freeze

  def perform(payload = {})
    return unless payload['provider'] == PROVIDER

    Array(payload['events']).each do |event|
      process_event(event)
    end
  end

  private

  # NOTE(rstankov): Documentation
  # https://dev.mailjet.com/guides/#what-is-delivered-to-your-webhook
  def process_event(event)
    delivery = find_delivery_for(event)

    return unless delivery

    case event['event']
    when 'sent' then add_sent delivery, time: extract_time(event)
    when 'open' then add_open delivery, time: extract_time(event)
    when 'click' then add_click delivery, time: extract_time(event)
    when 'bounce' then failed delivery, event, 'email_bounced'
    when 'blocked' then failed delivery, event, 'email_blocked'
    when 'unsub' then unsubscribe delivery, 'email_client_unsubscribe'
    end
  end

  def find_delivery_for(event)
    return if event['customcampaign'].blank?
    return unless event['customcampaign'].starts_with?('upcoming_page_message_')

    delivery = UpcomingPageMessageDelivery.find_by id: event['CustomID']

    return if delivery.blank?
    return unless delivery.mailjet_campaign == event['customcampaign'].gsub(':producthunt', '')

    delivery
  end

  def add_sent(delivery, time:)
    delivery.update! sent_at: time
  end

  def add_open(delivery, time:)
    return if delivery.opened_at?

    delivery.sent_at = time unless delivery.sent_at?
    delivery.opened_at = time
    delivery.save!
  end

  def add_click(delivery, time:)
    return if delivery.clicked_at?

    delivery.sent_at = time unless delivery.sent_at?
    delivery.opened_at = time unless delivery.opened_at?
    delivery.clicked_at = time
    delivery.save!
  end

  def extract_time(event)
    event['time'] ? Time.zone.at(event['time']) : Time.current
  end

  def failed(delivery, event, source)
    return unless error_related_to_user? event

    delivery.update!(failed_at: extract_time(event))
    unsubscribe(delivery, source)
  end

  def unsubscribe(delivery, source)
    Ships::Contacts::UnsubscribeSubscriber.call delivery.subscriber, source: source
  end

  # NOTE(rstankov): Documentation on errors:
  #   https://dev.mailjet.com/guides/?ruby#possible-values-for-errors
  def error_related_to_user?(event)
    ERRORS.include? event['error']
  end
end
