# frozen_string_literal: true

module GoldenKitty
  extend self

  # Edition

  def periodic_edition_phases
    GoldenKitty::Editions::PERIODIC_PHASES
  end

  def time_key_for_edition_phase(phase)
    GoldenKitty::Editions.time_key_for_phase(phase)
  end

  def phase_for_edition(edition, user = nil)
    GoldenKitty::Editions.phase_for(edition, user)
  end

  def phase_preview_for_edition(edition, phase_key, current_user)
    GoldenKitty::Editions.phase_preview_for(edition, phase_key, current_user)
  end

  def social_image_for_edition(edition)
    GoldenKitty::Social.image_for(edition: edition, subject: edition)
  end

  def social_text_for_edition(edition)
    GoldenKitty::Social.text_for(edition: edition, subject: edition)
  end

  def send_notification_confirmation(subscription)
    GoldenKittyMailer.subscribed(subscription).deliver_later if GoldenKitty::EmailNotifications.can_send_for?(subscription)
  end

  def schedule_send_email_notification(phase, edition)
    GoldenKitty::EmailNotificationWorker.perform_later phase, edition
  end

  # NOTE(Raj): Legacy. Should be deprecated when GKA editions code prior to 2022 are archived.
  def live_event_url
    'https://app.experiencewelcome.com/events/rPurvb/stages/epflG6'
  end

  # Category

  def phase_for_category(category, user = nil)
    GoldenKitty::Categories.phase_for(category, user)
  end

  def social_image_for_category(category)
    GoldenKitty::Social.image_for(edition: category.edition, subject: category)
  end

  # Nomination Phase

  def total_categories_for_nomination(edition)
    GoldenKitty::Nominations.total_categories(edition)
  end

  def first_category_for_nomination(edition:, user: nil)
    GoldenKitty::Nominations.first_category(edition: edition, user: user)
  end

  def nominations_for_category_by_user(category:, user:)
    GoldenKitty::Nominations.for_category_by_user(category: category, user: user)
  end

  def next_category_for_nomination(category)
    GoldenKitty::Nominations.next_category(category)
  end

  def prev_category_for_nomination(category)
    GoldenKitty::Nominations.prev_category(category)
  end

  def nomination_category_index(category)
    GoldenKitty::Nominations.category_index(category)
  end

  def nomination_suggestions_for_user(category:, user: nil)
    GoldenKitty::Nominations.category_suggestions_for_user(category: category, user: user)
  end

  # Voting Phase

  def first_category_for_voting(edition:, user: nil)
    GoldenKitty::Voting.first_available_category(edition: edition, user: user)
  end

  def voting_for_category(category:, user: nil)
    voting = GoldenKitty::Voting.new(category: category, user: user)

    return voting if voting.enabled?
  end

  # Policy

  def policy
    GoldenKitty::Policy
  end

  # HOF

  def hof_resolver_data(year)
    GoldenKitty::Hof.call(year)
  end
end
