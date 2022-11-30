# frozen_string_literal: true

# NOTE(rstankov): Ads System
#   Documentation: https://www.notion.so/teamhome1431/Ads-System-09fec1b5dfee49488fe5096705ddbe63
module Ads
  extend self

  def fill_interaction(interaction:)
    Ads::Fill.interaction(interaction)
  end

  def fill_newsletter(subject:, event_type:, request_info: {})
    Ads::Fill.newsletter(
      subject: subject,
      event: event_type,
      request_info: request_info,
    )
  end

  def find_web_ad(**args)
    find_for(application: 'web', **args)
  end

  def find_ios_ad(**args)
    find_for(application: 'ios', **args)
  end

  def find_android_ad(**args)
    find_for(application: 'android', **args)
  end

  def find_for(kind:, application:, topic_id: nil, bundle: nil, exclude_ids: [])
    bundles = Ads::TopicBundle.find_bundles(Array(topic_id), bundle: bundle)

    Ads::FindAd.call(
      kind: kind,
      bundles: bundles,
      application: application,
      exclude_ids: exclude_ids,
    )
  end

  def for_newsletter_post_ads(max_only: false)
    scope =
      Ads::Newsletter
      .joins(:budget)
      .merge(Ads::Budget.with_impressions.active)
      .where(newsletter_id: nil)
      .active
      .by_weight

    scope = scope.where(weight: scope.maximum(:weight)) if max_only
    scope
  end

  def for_newsletter_sponsor(max_only: false)
    scope =
      Ads::NewsletterSponsor
      .joins(:budget)
      .merge(Ads::Budget.with_impressions.active)
      .active
      .by_weight

    scope = scope.where(weight: scope.maximum(:weight)) if max_only
    scope
  end

  def trigger_interaction(
    channel:,
    kind:,
    user:,
    reference:,
    track_code:,
    request:
  )
    Ads::Jobs.interaction(
      channel: channel,
      kind: kind,
      user: user,
      reference: reference,
      track_code: track_code,
      request: request,
    )
  end

  def trigger_newsletter_event(subject:, event:, request_info: {})
    Ads::Jobs.newsletter(
      subject: subject,
      event: event,
      request_info: request_info,
    )
  end

  # NOTE(DZ): Support older mobile clients
  LEGACY_REFERENCES = {
    'alternative' => 'ph_alternative',
    'extension' => 'ph_extension',
    'home' => 'ph_home',
    'post' => 'ph_post',
    'topic' => 'ph_topic',
  }.freeze

  def validate_reference(ref)
    return ref if Ads::Interaction::ALLOWED_REFERENCES.include?(ref)
    return LEGACY_REFERENCES[ref] if LEGACY_REFERENCES.key?(ref)

    'unknown'
  end
end
