# frozen_string_literal: true

class Cron::Emails::DiscussionDigestWorker < ApplicationJob
  include ActiveJobHandleMailjetErrors

  queue_as :long_running

  def perform
    DiscussionsDigest.notifications.each do |receiver_id, notifications|
      user = User.find(receiver_id)
      DiscussionsMailer.digest(user, notifications).deliver_later if user.notification_preferences['send_comment_digest_email']
    end
  end
end
