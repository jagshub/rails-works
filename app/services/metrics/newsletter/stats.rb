# frozen_string_literal: true

module Metrics::Newsletter::Stats
  extend self

  def stats(formatter: nil)
    return mailjet_data if formatter.nil?

    formatter.call(mailjet_data)
  end

  def dashboard
    stats(formatter: Metrics::Newsletter::Formatter::Dashboard).sort { |a, b| b.send_start <=> a.send_start }
  end

  def retrieve_delivered_count(newsletter)
    data = stats(formatter: Metrics::Newsletter::Formatter::Retry)

    data.detect { |stat| stat.product_hunt_id == newsletter.id }&.delivered
  end

  def mailjet_data
    @stats_from_api ||= Rails.cache.fetch('mailjet_campaign_stats', expires_in: 1.minute) do
      Mailjet::Campaignoverview.all(sent: true, limit: 0, sort: { 'id' => 'desc' })
    end
  end
end
