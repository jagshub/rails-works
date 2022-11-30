# frozen_string_literal: true

module FriendSync
  extend self

  def sync_later(user, force: false)
    return if recently_synced?(user) && !force

    FriendSync::Worker.perform_later(user.id)
  end

  private

  def recently_synced?(user)
    user.last_friend_sync_at? && user.last_friend_sync_at > 24.hours.ago
  end
end
