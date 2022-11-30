# frozen_string_literal: true

# Note(TC): This award is one per-user (non-stackable). It can only be awarded by admin users
# via the admin interface.
module UserBadges::Badge::InRealLife
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
end
