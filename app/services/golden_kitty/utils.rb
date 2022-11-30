# frozen_string_literal: true

module GoldenKitty::Utils
  extend self

  NOMINATION_END_DATETIME = Time.zone.local(2020, 1, 18, 0)
  VOTING_END_DATETIME = Time.zone.local(2020, 1, 25, 7)

  def nomination_ended?
    Time.zone.now >= NOMINATION_END_DATETIME
  end

  def voting_ended?
    Time.zone.now >= VOTING_END_DATETIME
  end
end
