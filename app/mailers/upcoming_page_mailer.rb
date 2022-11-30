# frozen_string_literal: true

class UpcomingPageMailer < ApplicationMailer
  def digest(upcoming_page, start_time, end_time)
    email_campaign_name('upcoming_page_digest_mailer')

    scope = upcoming_page.subscribers_between(start_time, end_time)

    @upcoming_page = upcoming_page
    @user = upcoming_page.user

    @total_subscribers_count = scope.count
    @top_subscribers = scope.user.by_user_follower_count.limit(5)
    @rest_subscriber_count = @total_subscribers_count - @top_subscribers.size

    @maker_tasks = upcoming_page.maker_tasks.pending

    @unsubscribe_url = Notifications::UnsubscribeWithToken.url kind: 'ship', user: @user

    mail(
      to: @user.email,
      reply_to: CommunityContact::PREMIUM_SHIP,
      subject: "Weekly Report for #{ upcoming_page.name }",
    )
  end

  def featured(upcoming_page)
    @upcoming_page = upcoming_page
    @user = upcoming_page.user

    mail(
      to: @user.email,
      reply_to: CommunityContact::PREMIUM_SHIP,
      subject: 'Your Upcoming Page is scheduled for promotion 🚀',
    )
  end

  def import_finished(upcoming_page_email_import:, failed_count:, success_count:, duplicate_count:)
    email_campaign_name('upcoming_page_import')

    @duplicate_count = duplicate_count
    @success_count = success_count
    @failed_count = failed_count

    @upcoming_page = upcoming_page_email_import.upcoming_page
    @user = upcoming_page_email_import.upcoming_page.user

    @tracking_params = Metrics.url_tracking_params(medium: :email, object: :upcoming_page_import)

    mail(
      to: @user.email,
      reply_to: CommunityContact::PREMIUM_SHIP,
      subject: "Your subscriber import for #{ @upcoming_page.name } is done",
    )
  end

  def import_in_review(upcoming_page_email_import:)
    @upcoming_page = upcoming_page_email_import.upcoming_page
    @user = upcoming_page_email_import.upcoming_page.user

    mail(
      to: @user.email,
      reply_to: CommunityContact::PREMIUM_SHIP,
      subject: "Your subscriber import for #{ @upcoming_page.name } is in review",
    )
  end

  def import_invalid_file(upcoming_page_email_import:)
    @upcoming_page = upcoming_page_email_import.upcoming_page
    @user = upcoming_page_email_import.upcoming_page.user

    mail(
      to: @user.email,
      reply_to: CommunityContact::PREMIUM_SHIP,
      subject: "The subscriber import for #{ @upcoming_page.name } requires your attention",
    )
  end

  def import_notify_ph(upcoming_page_email_import:)
    @email_import = upcoming_page_email_import

    mail(
      to: CommunityContact::PREMIUM_SHIP,
      subject: 'A Ship subscriber import needs review',
    )
  end
end
