# frozen_string_literal: true

module FounderClub::Subscription
  extend self

  def active?(user)
    return false if user.nil?
    return true if Rails.configuration.settings.usernames(:founder_club_free_subscribers).include?(user.username)

    Payment::Subscription.active_for_user_in_project(user: user, project: :founder_club).exists?
  end
end
