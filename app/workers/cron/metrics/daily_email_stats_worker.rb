# frozen_string_literal: true

class Cron::Metrics::DailyEmailStatsWorker < ApplicationJob
  queue_as :long_running

  # NOTE(DZ): The most effective way to get campaign ID from mailjet is using
  # their website and searching by campaign name. You can get the ID from the
  # URL. Add name here because statcounters api does not return this.
  PRODUCTION_CAMPAIGNS = {
    7_653_652_242 => 'Product Follow Launch:producthunt',
    7_653_651_962 => 'mention_notification:producthunt',
    7_653_651_964 => 'new_follower_notification:producthunt',
    7_653_651_958 => 'friend_product_maker_notification:producthunt',
    7_653_652_012 => 'upcoming_page_digest_mailer:producthunt',
    7_653_651_972 => 'ship_stripe_discounts:producthunt',
    7_653_652_028 => 'ship_trial_expired:producthunt',
    7_653_651_960 => 'top_maker_notification',
    # TODO(DZ): Fetch IDs when they populate
    # User Badge Awarded
    # awarded_badges_notifications
  }.freeze

  TRANSACTIONAL_CAMPAIGNS = {
    7_717_293_768 => 'Product Launch Immediate:producthunt',
    7_717_293_766 => 'Product Launch Scheduled:productphunt',
    7_717_293_758 => 'Product Launch Post Launch:producthunt',
    7_717_293_762 => 'Consumer Welcome Mailer:producthunt',
    7_717_293_760 => 'Consumer Followup Mailer:producthunt',
    7_717_293_756 => 'Consumer NL CTA Mailer:producthunt',
    7_717_293_820 => 'User Initial Retention Drip:producthunt',
    7_717_293_764 => 'Maker Welcome Mailer:producthunt',
    7_717_293_770 => 'Maker Additional Resources Mailer:producthunt',
    7_717_293_772 => 'Maker Case Study Mailer:producthunt',
  }.freeze

  def perform
    Rails.logger.info 'DailyEmailStatsWorker: Fetching producthunt stats'
    External::MailjetApi.with_producthunt_account do
      PRODUCTION_CAMPAIGNS.each do |campaign_id, campaign_name|
        save_campaign_stat(campaign_id, campaign_name)
      end
    end

    Rails.logger.info 'DailyEmailStatsWorker: Fetching transactional stats'
    External::MailjetApi.with_transactional_account do
      TRANSACTIONAL_CAMPAIGNS.each do |campaign_id, campaign_name|
        save_campaign_stat(campaign_id, campaign_name)
      end
    end

    Rails.logger.info 'DailyEmailStatsWorker: Finished'
  end

  def save_campaign_stat(campaign_id, campaign_name)
    # NOTE(DZ): Fetch 25 hours of data representing today and the previous day.
    # This is to account for the time it takes for mailjet to process the data.
    # Mailjet's API returns the entire resolution (day) of data even if the
    # query only intersects one hour in the day.
    stats = External::MailjetApi.statcounters(
      id: campaign_id,
      from: 25.hours.ago,
      to: Time.now.in_time_zone,
    )

    stats.each do |stat|
      Metrics::MailjetStat.find_or_create_by_statcounters!(stat, campaign_name)
    end

    Rails.logger.info "DailyEmailStatsWorker: Fetched #{ stats.size } stats for #{ campaign_name }"
  end
end
