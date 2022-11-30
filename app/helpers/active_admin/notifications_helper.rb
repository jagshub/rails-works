# frozen_string_literal: true

module ActiveAdmin::NotificationsHelper
  def flags_for(grouping)
    grouped_flags = FLAGS_MAP[grouping] || []

    grouped_flags.select { |flag| Notifications::UserPreferences::FLAGS.include?(flag) }
  end

  FLAGS_MAP = {
    welcome: %i(send_onboarding_email),
    ph_updates: %i(send_announcement_browser_push
                   send_golden_kitty_email send_makers_festival_email),

    activity: %i(send_mention_email send_mention_browser_push send_comment_digest_email
                 send_new_follower_email send_new_follower_browser_push
                 send_shoutout_mention_email),

    maker_updates: %i(send_onboarding_post_launch_email send_dead_link_report_email send_featured_maker_email
                      send_maker_instructions_email send_maker_report_email),

    community_updates: %i(send_discussion_created_email send_collection_digest_email
                          send_friend_post_email send_friend_post_browser_push),

    ship: %i(send_upcoming_page_stats_email send_stripe_discount_email send_upcoming_page_promotion_scheduled_email),
  }.freeze
end
