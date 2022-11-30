# frozen_string_literal: true

class DripMails::CronWorker < ApplicationJob
  queue_as :mailers

  def perform
    DripMails::ScheduledMail.pending.find_each do |drip_mail|
      DripMails.deliver(drip_mail: drip_mail)
    end
  end
end
