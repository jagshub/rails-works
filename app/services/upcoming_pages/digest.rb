# frozen_string_literal: true

class UpcomingPages::Digest
  attr_reader :start_time, :end_time

  class << self
    def call(start_time, end_time)
      new(start_time, end_time).call
    end
  end

  def initialize(start_time, end_time)
    @start_time = start_time
    @end_time = end_time
  end

  def call
    UpcomingPage.find_each do |upcoming_page|
      new_subscribers = upcoming_page.subscribers_between(start_time, end_time)

      next if new_subscribers.count == 0
      next unless upcoming_page.user.send_upcoming_page_stats_email
      next if upcoming_page.user.email.blank?

      UpcomingPages::DigestMailerWorker.perform_later(upcoming_page, start_time.to_s, end_time.to_s)
    end
  end
end
