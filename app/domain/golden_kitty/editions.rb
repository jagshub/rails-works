# frozen_string_literal: true

module GoldenKitty::Editions
  extend self

  PERIODIC_PHASES = %i(result_announced voting_ended voting_started nomination_ended nomination_started launched).freeze

  PHASE_TIMESTAMP_KEY_MAP = {
    launched: nil,
    nomination_started: :nomination_starts_at,
    nomination_ended: :nomination_ends_at,
    voting_started: :voting_starts_at,
    voting_ended: :voting_ends_at,
    result_announced: :result_at,
  }.freeze

  def phase_for(edition, user = nil)
    return :voting_started if GoldenKitty::Voting.beta_user?(user)

    now = Time.zone.now

    PERIODIC_PHASES.each do |phase|
      key = time_key_for_phase(phase)
      next if key.blank?

      return phase if now >= edition.public_send(key)
    end

    :launched
  end

  def phase_preview_for(edition, phase_key, current_user)
    phase_key = phase_key&.to_sym || :invalid
    is_valid_phase = PERIODIC_PHASES.include?(phase_key)
    return phase_key if current_user.admin? && is_valid_phase

    # Note(Rahul): This is fallback for non-admins & if index number is wrong
    phase_for(edition, current_user)
  end

  def time_key_for_phase(phase)
    return PHASE_TIMESTAMP_KEY_MAP[phase] if PERIODIC_PHASES.include?(phase)

    raise ArgumentError, "phase: #{ phase } is not a recognised golden kitty edition phase."
  end
end
