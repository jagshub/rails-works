# frozen_string_literal: true

class GoldenKitty::EmailNotificationWorker < ApplicationJob
  def perform(phase, edition)
    case phase.to_sym
    when :nomination_started
      GoldenKitty::EmailNotifications.send_nomination_open(edition)
    when :voting_started
      GoldenKitty::EmailNotifications.send_voting_open(edition)
    end
  end
end
