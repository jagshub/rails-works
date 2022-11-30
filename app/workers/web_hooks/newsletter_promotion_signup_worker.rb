# frozen_string_literal: true

# This processes webhooks from DojoMojo via the Webhooks App
class WebHooks::NewsletterPromotionSignupWorker
  include Sidekiq::Worker

  def perform(payload = {})
    emails_by_campaign = Hash.new { |h, k| h[k] = [] }

    payload.each do |subscriber|
      emails_by_campaign[subscriber['CAMPAIGN_NAME']] << FatFingers.clean_up_typoed_email(subscriber['EMAIL']) if subscriber['EMAIL'].present?
    end

    emails_by_campaign.each do |campaign|
      process_subscribers_for_campaign(campaign)
    end
  end

  private

  def process_subscribers_for_campaign(campaign)
    campaign_name = campaign.first
    emails = campaign.second

    already_subscribed_daily = Subscriber.where(email: emails).with_newsletter_subscription(Newsletter::Subscriptions::DAILY).pluck(:email)
    already_subscribed_weekly = Subscriber.where(email: emails).with_newsletter_subscription(Newsletter::Subscriptions::WEEKLY).pluck(:email)
    need_to_subscribe = emails - already_subscribed_daily - already_subscribed_weekly

    # Note (Mike Coutermarsh): this stops us from sending double optin email because they are already opted in
    need_to_subscribe.each do |email|
      subscriber = Subscribers.register(email: email)
      subscriber.update!(email_confirmed: true)
    end

    need_to_subscribe.each do |email|
      send_opt_out_email(email, campaign_name) if subscribe_to_newsletter(email, campaign_name)
    end

    send_analytics_events(campaign_name: campaign_name,
                          already_subscribed_daily: already_subscribed_daily,
                          already_subscribed_weekly: already_subscribed_weekly,
                          need_to_subscribe: need_to_subscribe)
  end

  def send_opt_out_email(email, campaign_name)
    if campaign_name.include? 'Paris Getaway'
      NewsletterPromotionMailer.paris_prague_opt_out_email(email).deliver_later
      return
    end

    if campaign_name.include? 'upscribe'
      NewsletterPromotionMailer.upscribe_opt_out_email(email).deliver_later
      return
    end

    if campaign_name.include? 'Habit Summit Giveaway'
      NewsletterPromotionMailer.habit_opt_out_email(email).deliver_later
      return
    end

    if campaign_name.include? 'LiveLikeAVC'
      NewsletterPromotionMailer.live_like_opt_out_email(email).deliver_later
      return
    end

    if campaign_name.include? 'PH_GIVEAWAY_2021'
      NewsletterPromotionMailer.ph_giveaway(email).deliver_later

      return
    end

    NewsletterPromotionMailer.generic_opt_out_email(email).deliver_later
  end

  def subscribe_to_newsletter(email, campaign_name)
    Newsletter::Subscriptions.set email: email, status: Newsletter::Subscriptions::DAILY, tracking_options: { source: :promotion, source_details: campaign_name }
  end

  def send_analytics_events(campaign_name:, already_subscribed_daily:, already_subscribed_weekly:, need_to_subscribe:)
    already_subscribed_daily.each do |email|
      External::SegmentApi.track(event: 'newsletter_promotion_signup', properties: { campaign: campaign_name, result: 'already_subscribed_to_daily' }, anonymous_id: email)
    end

    already_subscribed_weekly.each do |email|
      External::SegmentApi.track(event: 'newsletter_promotion_signup', properties: { campaign: campaign_name, result: 'already_subscribed_to_weekly' }, anonymous_id: email)
    end

    need_to_subscribe.each do |email|
      External::SegmentApi.track(event: 'newsletter_promotion_signup', properties: { campaign: campaign_name, result: 'new_subscriber' }, anonymous_id: email)
    end

    External::SegmentApi.flush
  end
end
