# frozen_string_literal: true

# == Schema Information
#
# Table name: ads_interactions
#
#  id          :bigint(8)        not null, primary key
#  channel_id  :bigint(8)        not null
#  user_id     :bigint(8)
#  track_code  :string           not null
#  kind        :string           not null
#  reference   :string
#  ip_address  :string
#  user_agent  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  backfill_at :datetime
#
# Indexes
#
#  index_ads_interactions_created_at_kind_created_month  (created_at, kind, date_trunc('month'::text, created_at))
#  index_ads_interactions_on_channel_id_and_kind         (channel_id,kind)
#  index_ads_interactions_on_kind                        (kind) USING spgist
#  index_ads_interactions_on_track_code                  (track_code)
#  index_ads_interactions_on_user_id                     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (channel_id => ads_channels.id)
#

class Ads::Interaction < ApplicationRecord
  include Namespaceable

  belongs_to :user, optional: true
  belongs_to :channel, class_name: 'Ads::Channel', inverse_of: :interactions

  # NOTE(DZ): If you add an interaction type, you'll need to add an associated
  # counter with name "#{ kind }s_count" in channel and budget
  enum kind: {
    click: 'click',
    close: 'close',
    impression: 'impression',
  }

  WEB_REFERENCES = %w(
    ph_alternative
    ph_extension
    ph_home
    ph_post
    ph_posts_trending
    ph_product
    ph_product_about
    ph_search
    ph_topic
    ph_collection
  ).freeze

  MOBILE_REFERENCES = %w(
    ph_ios_home
    ph_ios_profile
    ph_ios_onboarding_login
    ph_ios_onboarding_info
    ph_ios_onboarding_notification
    ph_ios_onboarding_newsletter
    ph_ios_activity
    ph_ios_collections_management
    ph_ios_collections_list
    ph_ios_collections_detail
    ph_ios_discovery_home
    ph_ios_discovery_detail
    ph_ios_news
    ph_ios_discussion_detail
    ph_ios_story_detail
    ph_ios_settings
    ph_ios_settings_layout
    ph_ios_settings_notifications
    ph_ios_post_launch_related_posts
    ph_ios_post_launch_related_posts_list
    ph_ios_product_hub_related_products
    ph_ios_product_hub_related_products_list

    ph_android_home
    ph_android_profile
    ph_android_onboarding_login
    ph_android_onboarding_info
    ph_android_onboarding_notification
    ph_android_onboarding_newsletter
    ph_android_activity
    ph_android_collections_management
    ph_android_collections_list
    ph_android_collections_detail
    ph_android_discovery_home
    ph_android_discovery_detail
    ph_android_news
    ph_android_discussion_detail
    ph_android_related_posts
    ph_android_story_detail
    ph_android_settings
    ph_android_settings_layout
    ph_android_settings_notifications
    ph_android_post_launch_related_posts
    ph_android_post_launch_related_posts_list
    ph_android_product_hub_related_products
    ph_android_product_hub_related_products_list
  ).freeze

  ALLOWED_REFERENCES = (WEB_REFERENCES + MOBILE_REFERENCES).uniq

  scope :unique_clicks, lambda {
    select('distinct(coalesce(user_id::varchar, track_code))').click
  }

  delegate :budget, to: :channel
end
