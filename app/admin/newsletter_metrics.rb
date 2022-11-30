# frozen_string_literal: true

ActiveAdmin.register_page 'Newsletter Metrics' do
  menu label: 'Metrics', parent: 'Newsletters'

  content do
    campaign_stats = Metrics::Newsletter::Stats.dashboard

    table_for campaign_stats do
      column :send_start
      column :subject
      column :delivered
      column :opens
      column :clicks
      column :open_percentage
      column :click_percentage
      column('View') { |campaign| campaign && link_to('View', campaign.link) }
      column('View Report') do |campaign|
        # Note(AR): The campaign link is expected to look like: /newsletter/1234-some-title
        newsletter_id = campaign&.link&.gsub(%r{/newsletter/(\d+)([-\w]*)$}, '\1')
        next if newsletter_id.to_i == 0

        link_to('View Report', admin_newsletter_report_path(id: newsletter_id))
      end
    end
  end

  sidebar :daily_subscribers do
    daily_count = Rails.cache.fetch('campaign_stats_daily_count', expires_in: 5.minutes) do
      Subscriber.with_newsletter_subscription(Newsletter::Subscriptions::DAILY).with_email_confirmed.count
    end

    daily_count.to_s
  end

  sidebar :weekly_subscribers do
    weekly_count = Rails.cache.fetch('campaign_stats_weekly_count', expires_in: 5.minutes) do
      Subscriber.with_newsletter_subscription(Newsletter::Subscriptions::WEEKLY).with_email_confirmed.count
    end

    weekly_count.to_s
  end
end
