# frozen_string_literal: true

module DripMails
  extend self

  # Note(TC): This is the only place you would need to define mailer send_on
  # times relative to now and also the action which will be invoked by the delivery worker
  # to send the appropriate email.
  # The top most key is the kind of mailer and will become a drip_kind enum value.
  # https://www.notion.so/teamhome1431/0111b36647cc4e98ae9c172dbadfa8f4
  CAMPAIGNS = {
    consumer_onboarding: {
      initial_welcome: {
        qualified_at: nil,
        action: DripMails::Onboarding::Consumer::Welcome,
        campaign_name: 'Consumer Welcome Mailer',
      },
      followup_welcome: {
        qualified_at: 3.days,
        action: DripMails::Onboarding::Consumer::FollowupWelcome,
        campaign_name: 'Consumer Followup Mailer',
      },
      newsletter_signup_cta: {
        qualified_at: 1.week,
        action: DripMails::Onboarding::Consumer::NewsletterSignup,
        campaign_name: 'Consumer NL CTA Mailer',
      },
    },
    maker_onboarding: {
      initial_welcome: {
        qualified_at: nil,
        action: DripMails::Onboarding::Maker::Welcome,
        campaign_name: 'Maker Welcome Mailer',
      },
      launch_case_study: {
        qualified_at: 2.weeks,
        action: DripMails::Onboarding::Maker::CaseStudy,
        campaign_name: 'Maker Case Study Mailer',
      },
      additional_maker_resources: {
        qualified_at: 3.weeks,
        action: DripMails::Onboarding::Maker::AdditionalResources,
        campaign_name: 'Maker Additional Resources Mailer',
      },
    },
    post_launch: {
      scheduled_launch: {
        qualified_at: nil,
        action: DripMails::PostLaunch::ScheduledLaunch,
        campaign_name: 'Product Launch Scheduled',
      },
      immediate_launch: {
        qualified_at: nil,
        action: DripMails::PostLaunch::ImmediateLaunch,
        campaign_name: 'Product Launch Immediate',
      },
      post_launch: {
        qualified_at: 1.week,
        action: DripMails::PostLaunch::PostLaunch,
        campaign_name: 'Product Launch Post Launch',
      },
      two_week_post_launch: {
        qualified_at: 2.weeks,
        action: DripMails::PostLaunch::TwoWeekPostLaunch,
        campaign_name: 'Product Launch Two Week Post Launch',
      },
    },
    user_retention: {
      initial_no_engagement: {
        qualified_at: nil,
        action: DripMails::UserRetention::InitialNoEngagement,
        campaign_name: 'User Initial Retention Drip',
      },
    },
  }.freeze

  def begin_onboarding_drip(user:)
    DripMails::Onboarding.new(user: user).start
  end

  def begin_post_launch_drip(post:)
    DripMails::PostLaunch.new(post: post).start
  end

  def begin_user_retention_drip(user:)
    DripMails::UserRetention.new(user: user).start
  end

  def deliver(drip_mail:)
    DripMails::DeliveryWorker.perform_later(drip_mail: drip_mail)
  end

  def cron_worker
    DripMails::CronWorker
  end

  def user_retention_cron_worker
    DripMails::UserRetention::MailerWorker
  end

  def mailers_for(kind:)
    CAMPAIGNS[kind]
  end

  def campaign_name_for(kind:, mailer:)
    CAMPAIGNS[kind][mailer][:campaign_name]
  end

  def drip_kinds
    CAMPAIGNS.keys.inject({}) do |acc, key|
      acc[key] = key.to_s.dasherize
      acc
    end
  end
end
