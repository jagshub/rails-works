# frozen_string_literal: true

module UpcomingPages
  class FeatureUpcomingPage
    attr_reader :upcoming_page, :moderator

    MAX_FEATURED_UPCOMING_PAGES = 2

    class << self
      def call(upcoming_page, moderator)
        new(upcoming_page, moderator).call
      end
    end

    def initialize(upcoming_page, moderator)
      @upcoming_page = upcoming_page
      @moderator = moderator
    end

    def call
      trigger_event
      notify_user
      create_moderation_log
      unlist_previous_upcoming_pages
    end

    private

    def trigger_event
      Stream::Events::UpcomingPageFeatured.trigger(
        user: moderator,
        subject: upcoming_page,
        source: :admin,
      )
    end

    def notify_user
      return unless upcoming_page.user.send_upcoming_page_promotion_scheduled_email

      UpcomingPageMailer.featured(upcoming_page).deliver_later if upcoming_page.user.email.present?
    end

    def create_moderation_log
      ModerationLog.create!(
        reference: upcoming_page,
        moderator: moderator,
        message: 'Featured Upcoming Page',
      )
    end

    def unlist_previous_upcoming_pages
      featured_upcoming_page_count = upcoming_pages.count

      return if featured_upcoming_page_count <= MAX_FEATURED_UPCOMING_PAGES

      upcoming_pages.order(created_at: :asc)
                    .limit(featured_upcoming_page_count - MAX_FEATURED_UPCOMING_PAGES)
                    .update_all(featured_at: nil, status: UpcomingPage.statuses[:unlisted])
    end

    def upcoming_pages
      UpcomingPage.visible.featured.where(user: upcoming_page.user)
    end
  end
end
