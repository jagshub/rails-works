# frozen_string_literal: true

module UserBadges::Badge::Veteran
  extend UserBadges::Badge::Base
  extend self

  DEFAULT_STATUS = :awarded_to_user_and_visible
  MIN_YEARS = 5.years
  REQUIRED_KEYS = {
    identifier: ->(val) { val == UserBadges::AWARDS.index(self) },
  }.freeze

  def validate?(data:, user:)
    required_keys?(data) &&
      valid_key_values?(data) &&
      existing_badge_for_user(user).nil?
  end

  def update_or_create(data:, user:)
    Badges::UserAwardBadge.create!(
      subject: user,
      data: data,
    )
  end
end
