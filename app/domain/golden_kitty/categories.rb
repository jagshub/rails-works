# frozen_string_literal: true

module GoldenKitty::Categories
  extend self

  def phase_for(category, user = nil)
    edition_phase = category.edition.phase(nil, user)

    return :nomination if edition_phase == :nomination_started
    return :voting if voting_enabled?(edition_phase, category, user)

    :none
  end

  private

  def voting_enabled?(edition_phase, category, user = nil)
    return false unless edition_phase == :voting_started

    return true if category.voting_enabled_at.present? && Time.zone.now >= category.voting_enabled_at

    return GoldenKitty::Voting.available_category_ids_for_beta_users(category.edition).include?(category.id) if GoldenKitty::Voting.beta_user?(user)

    false
  end
end
