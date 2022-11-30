# frozen_string_literal: true

# == Schema Information
#
# Table name: mobile_devices
#
#  id                             :bigint(8)        not null, primary key
#  user_id                        :bigint(8)        not null
#  device_uuid                    :string
#  os                             :integer
#  os_version                     :string
#  app_version                    :string
#  push_notification_token        :string
#  one_signal_player_id           :string
#  last_active_at                 :date             not null
#  sign_out_at                    :date
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  device_model                   :string
#  send_mention_push              :boolean          default(TRUE), not null
#  send_new_follower_push         :boolean          default(TRUE), not null
#  send_friend_post_push          :boolean          default(TRUE), not null
#  send_comment_on_post_push      :boolean          default(TRUE), not null
#  send_reply_on_comments_push    :boolean          default(TRUE), not null
#  send_trending_posts_push       :boolean          default(TRUE), not null
#  send_community_updates_push    :boolean          default(TRUE), not null
#  send_product_request_push      :boolean          default(TRUE), not null
#  send_missed_post_push          :boolean          default(TRUE), not null
#  send_top_post_competition_push :boolean          default(TRUE), not null
#  send_product_mention_push      :boolean          default(TRUE), not null
#  send_friend_product_maker_push :boolean          default(TRUE), not null
#  send_visit_streak_ending_push  :boolean          default(TRUE), not null
#  send_vote_push                 :boolean          default(TRUE), not null
#
# Indexes
#
#  index_mobile_devices_on_user_id_and_device_uuid  (user_id,device_uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Mobile::Device < ApplicationRecord
  self.table_name = 'mobile_devices'

  self.ignored_columns = %i(send_marketing_push)

  belongs_to :user, counter_cache: :mobile_devices_count

  enum os: {
    android: 0,
    ios: 1,
  }

  SETTINGS = %i(
    send_comment_on_post_push
    send_community_updates_push
    send_friend_post_push
    send_friend_product_maker_push
    send_mention_push
    send_missed_post_push
    send_new_follower_push
    send_product_mention_push
    send_product_request_push
    send_reply_on_comments_push
    send_top_post_competition_push
    send_trending_posts_push
    send_visit_streak_ending_push
    send_vote_push
  ).freeze

  scope :push_enabled, -> { where.not(push_notification_token: nil).where.not(one_signal_player_id: nil) }

  class << self
    def device_for(user:, request:)
      return if request.headers['X-Visitor'].blank?
      return if user.blank?

      user_agent_info = Mobile::ExtractInfoFromHeaders.get_user_agent_info(request)

      HandleRaceCondition.call do
        mobile_device = Mobile::Device.find_by(user: user, device_uuid: request.headers['X-Visitor'])

        if mobile_device.present?
          update_device = {}
          update_device[:os] = os[user_agent_info[:os]] if os[user_agent_info[:os]].present?
          %i(os_version app_version device_model).each do |property|
            update_device[property] = user_agent_info[property] if user_agent_info[property].present?
          end

          mobile_device.update!(update_device)
          return mobile_device
        end

        settings = {}
        SETTINGS.each do |property|
          settings[property] = true
        end
        ## Create device
        ::Mobile::Device.create!(
          user: user,
          os: os[user_agent_info[:os]],
          os_version: user_agent_info[:os_version],
          app_version: user_agent_info[:app_version],
          device_model: user_agent_info[:device_model],
          last_active_at: Time.zone.now.to_date,
          device_uuid: request.headers['X-Visitor'],
          **settings,
        )
      end
    end

    def enabled_push_for(user_id:, option: nil)
      return none if option.present? && !column_names.include?(option)

      condition = { user_id: user_id }
      condition[option] = true if option.present?
      push_enabled.where(condition)
    end
  end
end
