# frozen_string_literal: true

module Posts::CanPostCheck
  extend self

  def call(user)
    return false unless user.verified?

    return true if allowlist?(user)
    return false if blocklist?(user)
    return test_regular_user?(user) if user.user?

    true
  end

  private

  def allowlist?(user)
    user.admin? || user.can_post?
  end

  def blocklist?(user)
    user.potential_spammer? || user.spammer? || user.company? || user.bad_actor?
  end

  def test_regular_user?(user)
    return false if user.created_at > 1.week.ago && !Newsletter::Subscriptions.active?(user: user)

    true
  end
end
