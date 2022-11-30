# frozen_string_literal: true

class DripMails::UserRetention::MailerWorker < ApplicationJob
  queue_as :long_running

  def perform
    User.where(last_active_at: ::DripMails::UserRetention::INACTIVTIY_PERIOD.ago).credible.find_each do |user|
      next if on_retention_drip?(user) || !user.can_receive_email?

      ::DripMails.begin_user_retention_drip(user: user)
    end
  end

  private

  # Note (TC): The intention is for a user to ever only get this drip campaign once.
  # They cannot be re-subscribed to it once if they have already have been on it - regardless
  # of outcome.
  def on_retention_drip?(user)
    ::DripMails::ScheduledMail.where(user_id: user.id, drip_kind: 'user_retention').exists?
  end
end
