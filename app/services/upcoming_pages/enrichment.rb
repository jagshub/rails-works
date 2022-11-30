# frozen_string_literal: true

module UpcomingPages::Enrichment
  extend self

  def call(email)
    email = email.downcase
    profile = ClearbitProfiles.enrich_from_email(email)

    # NOTE(vesln): in the future, we may want to reindex the data if it's "old"
    return update_contacts(email, profile) if profile.present?
  end

  def update_contacts(email, profile)
    return if profile.blank?
    return if email.blank?

    ShipContact.where(email: email).update_all(
      clearbit_person_profile_id: profile.id,
    )
  rescue PG::TRDeadlockDetected
    nil
  end
end
