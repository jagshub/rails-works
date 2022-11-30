# frozen_string_literal: true

module Discussion::Thread::Follow
  extend self

  def call(thread:, user:)
    return if thread.blank? || user.blank?

    is_owner = thread.user == user

    return unless is_owner

    thread.subscriptions.find_or_create_by! subscriber: user.subscriber
  end
end
