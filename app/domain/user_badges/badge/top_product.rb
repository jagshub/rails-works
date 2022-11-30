# frozen_string_literal: true

module UserBadges::Badge::TopProduct
  extend UserBadges::Badge::Base
  extend self

  DEFAULT_STATUS = :awarded_to_user_and_visible
  REQUIRED_KEYS = {
    identifier: ->(val) { val == UserBadges::AWARDS.index(self) },
    for_post_id: ->(val) { val.present? },
  }.freeze

  def stackable?
    true
  end

  def validate?(data:, user:)
    required_keys?(data) &&
      valid_key_values?(data) &&
      unique_post_award_for_user?(data, user)
  end

  def update_or_create(data:, user:)
    Badges::UserAwardBadge.create!(
      subject: user,
      data: data,
    )
  end

  private

  def unique_post_award_for_user?(data, user)
    !user.badges.with_data(
      identifier: UserBadges::AWARDS.index(self),
      for_post_id: data[:for_post_id],
    ).exists?
  end
end
