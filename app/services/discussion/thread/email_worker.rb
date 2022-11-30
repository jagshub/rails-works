# frozen_string_literal: true

class Discussion::Thread::EmailWorker < ApplicationJob
  include ActiveJobHandleDeserializationError
  NOTIFICATION_SETTING = 'send_discussion_created_email'

  def perform(thread)
    return if thread.destroyed? || thread.trashed? || thread.hidden?
    return if thread.subject_type != 'MakerGroup'
    return if thread.beta?

    users = thread.user
                  .followers
                  .where("(notification_preferences->>'#{ NOTIFICATION_SETTING }')::boolean = ?", true)
                  .joins(:subscriber)
                  .where(notifications_subscribers: { email_confirmed: true })
                  .where.not(notifications_subscribers: { email: nil })

    users.find_each do |user|
      DiscussionsMailer.new_discussion(thread, user).deliver_later
    end
  end
end
