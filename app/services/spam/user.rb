# frozen_string_literal: true

module Spam::User
  extend self

  NON_CREDIBLE_ROLES = %w(potential_spammer spammer company).freeze
  SANDBOXED_ROLES    = %w(potential_spammer spammer company).freeze
  SPAMMER_ROLES      = %w(potential_spammer spammer).freeze

  def mark(user, log)
    Spam::User::MarkAsSpammer.mark(user, log)
  end

  def unmark(user, log)
    Spam::User::MarkAsSpammer.unmark(user, log)
  end

  def credible_role?(user)
    return false if user.blank?

    !NON_CREDIBLE_ROLES.include?(user.role)
  end

  def sandboxed_user?(user)
    SANDBOXED_ROLES.include?(user.role)
  end

  def spammer_user?(user)
    SPAMMER_ROLES.include?(user.role)
  end

  def potential_spammer?(twitter_response)
    Spam::User::PotentialSpammer.call(twitter_response)
  end
end
