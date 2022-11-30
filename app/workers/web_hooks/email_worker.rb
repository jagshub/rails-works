# frozen_string_literal: true

# NOTE(ayrton) Jobs are created from our webhooks app using the Sidekiq
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

class WebHooks::EmailWorker
  include Sidekiq::Worker
  include Admin::MailTest

  PROVIDER = 'mailjet'
  EVENTS = ['event', 'customcampaign', 'email'].freeze
  USER_SIDE_ERRORS = ['user unknown', 'mailbox inactive', 'invalid domain', 'no mail host'].freeze

  def perform(payload = {})
    return unless payload['provider'] == PROVIDER

    if payload['events'].is_a?(Array)
      Array(payload['events']).each do |event|
        event['Payload'] = parse_payload(event) if event['Payload'].present?
        report_test_payload(event) if test_event?(event)
        process_event(event)
      end
    else
      event = payload['events']
      event['Payload'] = parse_payload(event) if event['Payload'].present?
      report_test_payload(event) if test_event?(event)
      process_event(event)
    end
  end

  private

  def process_event(event)
    return unless valid_event? event

    if newsletter_event? event
      process_newsletter_event event
    elsif announcement_event? event
      process_announcements_event event
    end
  end

  def process_newsletter_event(event)
    case event['event']
    when 'bounce', 'blocked'
      unsubscribe_from_newsletter(event, :email_bounced) if error_related_to_user? event
    when 'unsub'
      unsubscribe_from_newsletter(event, :email_client_unsubscribe)
    when 'open', 'click', 'sent'
      Metrics::NewsletterEventWorker.perform_async event
    end
  end

  def process_announcements_event(event)
    case event['event']
    when 'bounce', 'blocked'
      unsubscribe_from_announcements(event) if error_related_to_user? event
    when 'unsub'
      unsubscribe_from_announcements(event)
    end
  end

  def newsletter_event?(event)
    event['customcampaign'].starts_with?('Daily') || event['customcampaign'].starts_with?('Weekly')
  end

  def announcement_event?(event)
    event['customcampaign'].starts_with?('Announcement') || event['customcampaign'].starts_with?('mj.nl=')
  end

  # NOTE(rstankov): Documentation on events:
  #   https://dev.mailjet.com/guides/?ruby#events
  def valid_event?(event)
    (EVENTS - event.keys).empty?
  end

  # NOTE(rstankov): Documentation on errors:
  #   https://dev.mailjet.com/guides/?ruby#possible-values-for-errors
  def error_related_to_user?(event)
    USER_SIDE_ERRORS.include? event['error']
  end

  def parse_payload(event)
    payload = JSON.parse(event['Payload'])
    # NOTE(DZ): Mailjet's payload seems to be sending double escaped json
    # strings, _sometimes_
    payload = JSON.parse(payload) if payload.is_a? String
    payload
  rescue JSON::ParserError
    {}
  end

  def unsubscribe_from_newsletter(event, track_source)
    HandleRaceCondition.call do
      Newsletter::Subscriptions.set email: event['email'], status: Newsletter::Subscriptions::UNSUBSCRIBED, tracking_options: { source: track_source }
    end
  end

  def unsubscribe_from_announcements(event)
    HandleRaceCondition.call do
      user = User.find_by_email event['email']
      return unless user

      form = My::UserSettings.new(user)
      form.update("send_ph_updates_email": false)
    end
  end

  # NOTE(DZ): Trigger warning in sentry to report webhook payload
  def report_test_payload(event)
    ErrorReporting.report_warning_message(
      'Mailjet Test Payload received', extra: { event: event }
    )
  end
end
