# frozen_string_literal: true

# Note(TC): This is the base badge all other badges will be extended from.
# It provides some basic methods that all badges will be using. From the extended
# badge you can add/override these methods
module UserBadges::Badge::Base
  extend self

  BASE_REQUIRED_KEYS = {
    status: ->(val) { !val.nil? && Badges::UserAwardBadge.statuses.include?(val) },
  }.freeze

  def progress_requirement
    nil
  end

  def progress(*)
    nil
  end

  # Can it be awarded multiple times per user?
  def stackable?
    false
  end

  def send_notifications?
    true
  end

  private

  def required_keys?(data)
    required_keys = BASE_REQUIRED_KEYS.merge(self::REQUIRED_KEYS)
    required_keys.keys.to_set
                 .subset?(data.keys.to_set)
  end

  def valid_key_values?(data)
    required_keys = BASE_REQUIRED_KEYS.merge(self::REQUIRED_KEYS)
    required_keys.all? { |(key, proc)| proc.call(data[key]) }
  end

  def existing_badge_for_user(user, identifier)
    user.badges.with_data(identifier: identifier).first
  end
end
