# frozen_string_literal: true

# Note(TC): Awarded manually
module UserBadges::Badge::BetaTester
  extend UserBadges::Badge::Base
  extend self

  DEFAULT_STATUS = :awarded_to_user_and_visible
  REQUIRED_KEYS = {
    identifier: ->(val) { val == UserBadges::AWARDS.index(self) },
  }.freeze

  def validate?(**_args)
    false
  end

  def update_or_create(**_args)
    nil
  end

  def send_notifications?
    false
  end
end
