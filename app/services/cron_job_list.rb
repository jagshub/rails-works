# frozen_string_literal: true

module CronJobList
  extend self

  JOBS = {
    every_two_minutes: [
      Posts::UpdateCurrentDailyRankingWorker,
    ],

    every_ten_minutes: [
      Cron::Spam::SimilarVotesWorker,
      Cron::Spam::SiblingUsersWorker,
      Karma.refresh_points_worker,
      Cron::External::PgHeroWorker,
      DripMails.cron_worker,
      Posts::NotifyAboutFeaturedPostsWorker,
      Posts::UpdateCurrentWeeklyAndMonthlyRankingWorker,
    ],

    every_hour: [
      Products::UpdateVoteCountsHourlyWorker,
      Cron::Ship::DeliverContinuousMessagesWorker,
      Cron::External::SitemapWorker,
      # NOTE(DZ): This job only runs at 10 PST everyday
      Cron::Products::NewLaunchUpdate,
      Crypto::Currency.refresh_prices_worker,
      Search.index_cron_worker,
      Search::Workers::CalculateTrendingQueries,
      Iterable::PostLaunchedEventWorker,
      Ads::AlertSalesWorker,
      Cron::Notifications::VisitStreakReminderWorker,
      Cron::Emails::UpcomingPostsLaunchesWorker,
    ],

    # Runs every day at 02:00 PST
    every_day: [
      Cron::Emails::TopMakerWorker,
      Cron::Emails::CollectionDigestWorker,
      Cron::Emails::MakerReportWorker,
      Cron::Emails::DiscussionDigestWorker,
      Cron::Emails::NudgeLaunchWorker,
      Cron::Emails::MissedProductsWorker,
      Cron::BadgesWeeklyMonthlyWorker,
      Badges::FinalizeDailyTopPostBadgesWorker,
      Cron::SlackNotifications::PostsForFeaturingDailyWorker,
      Cron::Metrics::DailyEmailStatsWorker,
      Cron::Ship::EndSubscriptionsWorker,
      Ships::SyncPaymentReportsWorker,
      Cron::FileExports::CleanupWorker,
      Cron::Jobs::RenewalNotificationWorker,
      Cron::Spam::UserChecksWorker,
      Cron::Spam::DailyTwitterSuspensionCheckWorker,
      Cron::Notifications::PushNotificationSyncWorker,
      Cron::Notifications::PushNotificationMissedPostWorker,
      Clearbit::PersonBatchEnrichWorker,
      # NOTE(JL): Commenting this out temporarily, we'll be retooling its content soon
      # DripMails.user_retention_cron_worker,
      UserBadges.gemologist_progress_worker,
      TwitterFollowers.refresh_worker,
      Cron::DeactivateExpiredBanners,
      Cron::CleanMultipleInProgressContributorBadges,
      Cron::Products::UpdateBadgesFromYesterday,
      Cron::Posts::StalePreLaunchedPostsWorker,
      Cron::HouseKeeping::ProductsWorker,
      Cron::External::PipedriveDealsWorker,
      Users::VisitStreaks::EndExpiredStreaksWorker,
    ],

    # Runs every day at 16:00 PST
    every_day_end: [
      Cron::Notifications::PushNotificationTopPostCompetitionWorker,
      UserBadges.top_product_worker,
      Cron::Emails::NotifyAboutAwardedBadgesWorker,
    ],

    # Runs every Monday at 09:00 PST
    every_monday: [
      UpcomingPages::DigestWorker,
      Cron::AutolockPostsWorker,
      Badges::GenerateWeeklyTopPostTopicBadgesWorker,
    ],

    # Runs every Wednesday at 09:00 PST
    every_wednesday: [
      Cron::Ship::EndTrialRemindersWorker,
      UserBadges.veteran_worker,
    ],

    # Runs every Thursday at 09:00 PST
    every_thursday: [
      Cron::Jobs::DeliverNewJobsWorker,
    ],

    # Runs on 1st of every month at 00:00 PST
    every_month: [
      Cron::HouseKeeping::MaintainWorker,
      Badges::GenerateMonthlyTopPostTopicBadgesWorker,
    ],
  }.freeze

  def schedule_all(period)
    start = Time.current

    log "Cron scheduling started: #{ period } at #{ start }"

    JOBS.fetch(period).each do |job|
      schedule_job job
    end

    finish = Time.current

    log "Cron scheduling finished: #{ period } at #{ finish } (#{ finish - start }s)"
  rescue KeyError => e
    ErrorReporting.report_exception(e, extra: { key: period.to_s })
    log "Cron scheduling failed: Invalid period #{ period }"
  end

  private

  def schedule_job(job)
    job.perform_later
  rescue StandardError => e
    ErrorReporting.report_error(e, extra: { job: job.to_s })
    log "Enqueueing #{ job } failed: #{ e }"
  end

  def log(message)
    Rails.logger.info message
  end
end
