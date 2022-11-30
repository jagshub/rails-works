# frozen_string_literal: true

class Metrics::NewsletterEventWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'tracking'

  def perform(event)
    return unless valid_payload(event, ['email', 'CustomID', 'time'])

    newsletter_id, subscriber_id, newsletter_variant_id = event['CustomID'].split('-')

    newsletter = Newsletter.find_by(id: newsletter_id)
    return if newsletter.blank?

    subscriber = Subscriber.find_by(id: subscriber_id) || Subscriber.find_by(email: event['email'])
    return if subscriber.blank?

    datetime = parse_time event['time']
    return unless datetime

    trigger_ads_job(event, newsletter.id, event['event'])
    trigger_ads_sponsor_job(event, event['event'])

    return if event['event'] == 'sent' && (newsletter_variant_id.nil? || !NewsletterVariant.exists?(id: newsletter_variant_id))

    NewsletterEvent.create!(
      event_name: event['event'],
      time: datetime,
      subscriber_id: subscriber.id,
      newsletter_id: newsletter.id,
      link_url: event['url'],
      link_section: Newsletter::SectionForLink.call(newsletter, event['url']),
      ip: event['ip'],
      geo: event['geo'],
      agent: event['agent'],
      newsletter_variant_id: newsletter_variant_id,
    )
  end

  private

  # TODO(DZ): Remove usage of newsletter_id after deprecating old ads
  def trigger_ads_job(event, newsletter_id, type)
    ad = Ads::Newsletter.find_by(newsletter_id: newsletter_id)

    if ad.blank?
      ad_id = fetch_from_event_payload(event, 'post_ad_id')
      ad = Ads::Newsletter.find_by(id: ad_id) if ad_id
    end

    valid = Ads::Newsletter::BUDGET_COUNTERS.key?(type)
    # NOTE(DZ): Clicks are tracked by ads_controller
    return unless ad.present? && valid && type != 'click'

    Ads.trigger_newsletter_event subject: ad, event: type
  end

  def trigger_ads_sponsor_job(event, type)
    valid = Ads::Newsletter::BUDGET_COUNTERS.key?(type)
    return if type == 'click' || !valid

    sponsor_id = fetch_from_event_payload(event, 'sponsor_id')
    return if sponsor_id.blank?

    sponsor = Ads::NewsletterSponsor.find_by(id: sponsor_id)
    return if sponsor.blank?

    Ads.trigger_newsletter_event subject: sponsor, event: type
  end

  def valid_payload(event, fields)
    fields.each { |field| return false if event[field].blank? }

    true
  end

  def parse_time(timestamp)
    DateTime.strptime(timestamp.to_s, '%s')
  rescue ArgumentError
    nil
  end

  # NOTE(DZ): Payloads from WebHooks::EmailWorker should be properly parsed
  # into a ruby hash, however during testing, sometimes the payload was double
  # escaped.
  def fetch_from_event_payload(event, field)
    event['Payload'].fetch(field, nil)
  rescue NoMethodError => e
    ErrorReporting.report_error_message(e.message, extras: e, event: event)
    nil
  end
end
