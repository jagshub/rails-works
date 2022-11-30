# frozen_string_literal: true

module Iterable
  extend self

  ALLOWED_EVENTS = %w(
    new_user
    post_launched
    post_launch_scheduled
    onboarding_reason_selected
    mark_visit_streak
    new_badge_earned
    new_follower
    new_maker
    user_verified_mail
    launches_missed
  ).freeze

  def trigger_event(event_name, email:, user_id: nil, data_fields: {})
    raise 'Iterable event not allowed.' unless ALLOWED_EVENTS.include?(event_name)
    return if email.blank?

    Iterable::TriggerEventWorker.perform_later(event_name: event_name, email: email, user_id: user_id, data_fields: data_fields)
  end

  def trigger_bulk_event(events)
    # NOTE(JL): events should be in the same format as trigger_event above. Iterable requires an event name,
    # email, user id, and a set of data fields if necessary

    events.each do |e|
      raise "Iterable event not allowed: #{ e[:eventName] }" unless ALLOWED_EVENTS.include?(e[:eventName])
    end

    Iterable::TriggerBulkEventWorker.perform_later(events)
  end
end
