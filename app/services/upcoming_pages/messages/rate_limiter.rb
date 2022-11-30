# frozen_string_literal: true

class UpcomingPages::Messages::RateLimiter
  def self.limit_reached?(message)
    new(message).limit_reached?
  end

  attr_reader :upcoming_page, :message

  def initialize(message)
    @message = message
    @upcoming_page = message.upcoming_page
  end

  def limit_reached?
    return false if message.draft?
    return false if rate_limit_whitelisted?
    return true if message_blacklisted?

    return true if free_message_limit_reached?
    return true if daily_limit_reached?

    false
  end

  private

  def message_blacklisted?
    Rails.configuration.settings.usernames(:upcoming_page_message_blacklisted).include? upcoming_page.user.username
  end

  def rate_limit_whitelisted?
    Rails.configuration.settings.usernames(:upcoming_page_rate_limit_whitelisted).include? upcoming_page.user.username
  end

  def free_message_limit_reached?
    return false unless upcoming_page.account.free?

    limit = Rails.configuration.settings.upcoming_page_message_free_send_limit.to_i
    limit = 10_000 if limit.zero?

    message.to.count > limit
  end

  def daily_limit_reached?
    today_deliveries_count > upcoming_page.subscriber_count * 1.5
  end

  def today_deliveries_count
    UpcomingPageMessageDelivery
      .joins(:message).where('upcoming_page_messages.upcoming_page_id' => upcoming_page.id)
      .where('sent_at > ?', 24.hours.ago)
      .count
  end
end
