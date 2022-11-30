# frozen_string_literal: true

module Graph::Types
  class ViewerType < BaseObject
    include ::NewRelic::Agent::MethodTracer

    field :id, ID, null: true
    field :email, String, null: true
    field :email_verified, Boolean, null: false, resolver_method: :email_verified?
    field :can_new_upcoming_page, resolver: Graph::Resolvers::Can.build(:new) { UpcomingPage.new }
    field :can_manage_ship, resolver: Graph::Resolvers::Can.build(:manage) { :ship }
    field :can_use_ship_trial, resolver: Graph::Resolvers::Can.build(:trial) { ShipSubscription.new }
    field :can_claim_aws_credits, resolver: Graph::Resolvers::Can.build(:claim_aws_credits) { ShipSubscription.new }
    field :can_create_posts, resolver: Graph::Resolvers::Can.build(:create) { Post }
    field :can_create_discussion, resolver: Graph::Resolvers::Can.build(:create) { ::Discussion::Thread }
    field :notification_feed_items_unread_count, Integer, null: true
    field :notification_feed_last_seen_at, Graph::Types::DateTimeType, null: true
    field :moderation, Graph::Types::ModerationType, null: true
    field :external_moderation, Graph::Types::ExternalModerationType, null: true
    field :is_admin, Boolean, null: false, resolver_method: :admin?
    field :is_external_moderator, Boolean, null: false, resolver_method: :external_moderator?
    field :features, [String], null: false
    field :show_cookie_policy, Boolean, null: false
    field :is_onboarding_captcha_disabled, Boolean, null: false, resolver_method: :captcha_disabled?
    field :has_completed_signup_onboarding, Boolean, null: false, resolver_method: :completed_signup_onboarding?
    field :is_impersonated, Boolean, null: false, resolver_method: :impersonated?
    field :settings, Graph::Types::SettingsType, null: true
    field :has_slack_bot_installed, Boolean, null: false, resolver_method: :slack_bot_installed?
    field :has_newsletter_subscription, Boolean, null: false, resolver_method: :newsletter_subscription?
    field :has_jobs_newsletter_subscription, Boolean, null: false, resolver_method: :jobs_newsletter_subscription?
    field :has_founder_club_subscription, Boolean, null: false, resolver_method: :founder_club_subscription?
    field :collections, resolver: Graph::Resolvers::Viewer::CollectionsSearchResolver
    field :upcoming_pages, Graph::Types::UpcomingPageType.connection_type, max_page_size: 200, resolver: Graph::Resolvers::UpcomingPages::UserPagesResolver, null: false, connection: true
    field :ship, resolver: Graph::Resolvers::Ships::BillingResolver
    field :user, Graph::Types::UserType, null: true, resolver_method: :current_user
    field :payment_subscription_active, resolver: Graph::Resolvers::Payment::ActiveSubscriptionsResolver
    field :job_with_subscriptions, [Graph::Types::JobType], null: false
    field :founder_club_referrals, resolver: Graph::Resolvers::FounderClub::ReferralsResolver
    field :founder_club_claimed_deals, Graph::Types::FounderClubDealType.connection_type, max_page_size: 20, resolver: Graph::Resolvers::FounderClub::ClaimedDealsSearchResolver, null: true, connection: true
    field :device_type, String, null: false
    field :is_ship_maker, Boolean, null: false, resolver_method: :ship_maker?
    field :analytics_identify_json, Graph::Types::JsonType, null: false
    field :is_account_suspended, Boolean, null: false, resolver_method: :account_suspended?
    field :flash_alert, String, null: true, resolver_method: :flash_alert
    field :notice, resolver: Graph::Resolvers::ViewerNotice
    field :draft_posts, [Graph::Types::PostDraftType], null: false
    field :has_posts, Boolean, null: false
    field :ab_test, resolver: Graph::Resolvers::AbTestResolver
    field :ab_test_active_participations, [Graph::Types::AbTestType], null: false
    field :visit_streak_duration, Int, null: false
    field :recent_launch, Graph::Types::PostType, resolver: Graph::Resolvers::RecentLaunch, null: true
    field :intercom_user_hash, String, null: true

    def id
      current_user&.id
    end

    def email
      current_user&.email
    end

    def founder_club_claimed_deals
      current_user&.founder_club_claimed_deals || []
    end

    def email_verified?
      current_user&.verified? || false
    end

    def moderation
      true if current_user&.admin?
    end

    def external_moderation
      true if current_user&.admin? || current_user&.external_moderator?
    end

    def notification_feed_items_unread_count
      current_user&.notification_feed_items_unread_count || 0
    end

    def notification_feed_last_seen_at
      current_user&.notification_feed_last_seen_at
    end

    def settings
      My::UserSettings.new(current_user) if logged_in?
    end

    def slack_bot_installed?
      return false unless logged_in?

      SlackBot.active_for?(current_user)
    end

    def newsletter_subscription?
      return false unless logged_in?

      ::Newsletter::Subscriptions.active?(user: current_user)
    end

    def jobs_newsletter_subscription?
      return false unless logged_in?

      current_user.subscriber.jobs_newsletter_subscription == Jobs::Newsletter::Subscriptions::SUBSCRIBED
    end

    def founder_club_subscription?
      return false unless logged_in?

      FounderClub.active_subscription?(user: current_user)
    end

    def admin?
      current_user&.admin? || false
    end

    def external_moderator?
      current_user&.external_moderator? || false
    end

    def job_with_subscriptions
      current_user&.jobs&.with_active_subscription || []
    end

    def device_type
      context[:request_info].device_type
    end

    def captcha_disabled?
      UserOnboarding.captcha_disabled?
    end

    def completed_signup_onboarding?
      return false unless logged_in?

      UserOnboarding.completed? current_user
    end

    def impersonated?
      !!context[:impersonated]
    end

    def ship_maker?
      return false unless logged_in?

      ApplicationPolicy.can?(current_user, :manage, :ship) || current_user.ship_account_member_associations.any?
    end

    def analytics_identify_json
      return {} unless logged_in?

      Metrics.super_properties(current_user)
    end

    def logged_in?
      !!context[:current_user]
    end

    def admin?
      current_user&.admin? || false
    end

    def features
      Features.enabled_features(current_user)
    end

    def current_user
      context[:current_user]
    end

    def show_cookie_policy
      CookiePolicy.needed?(
        country_code: context[:request].headers.env['HTTP_CF_IPCOUNTRY'],
        cookies: context[:cookies],
      )
    end

    def account_suspended?
      !!current_user&.bad_actor?
    end

    def flash_alert
      context[:request].flash[:alert]
    end

    def draft_posts
      return [] unless current_user

      current_user.post_drafts.incomplete.order(updated_at: :desc) || []
    end

    def has_posts
      return 0 unless current_user

      current_user.posts_count > 0
    end

    def visit_streak_duration
      ::UserVisitStreak.visit_streak_duration(current_user)
    end

    def ab_test
      AbTest.variant_for(ctx: context, test: test_name)
    end

    def ab_test_active_participations
      AbTest.active_tests_for(ctx: context)
    end

    def intercom_user_hash
      return unless logged_in?

      External::Intercom.user_hash(current_user)
    end
  end
end
