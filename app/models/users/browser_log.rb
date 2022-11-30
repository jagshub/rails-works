# frozen_string_literal: true

# == Schema Information
#
# Table name: users_browser_logs
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)        not null
#  browsers   :string           default([]), is an Array
#  devices    :string           default([]), is an Array
#  platforms  :string           default([]), is an Array
#  countries  :string           default([]), is an Array
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_browser_logs_on_user_id  (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Users::BrowserLog < ApplicationRecord
  include Namespaceable
  belongs_to :user, inverse_of: :browser_logs

  class << self
    def append_to_user(user, user_agent, country)
      AppendToUser.call(user, user_agent, country)
    end
  end

  module AppendToUser
    extend self

    def call(user, user_agent, country)
      return unless should_update?(user, user_agent, country)

      HandleRaceCondition.call(max_retries: 3, transaction: true) do
        rec = Users::BrowserLog.find_or_initialize_by(user: user)

        append_browser_info(rec, user_agent)
        append_if_necessary(rec.countries, country)

        rec.save!
        user.update! last_user_agent: Utf8Sanitize.call(combine(user_agent, country))
      end
    end

    private

    def append_browser_info(rec, user_agent)
      browser = ::Browser.new(user_agent)

      append_if_necessary(rec.browsers, browser.name)
      append_if_necessary(rec.devices, browser.device.name)
      append_if_necessary(rec.platforms, browser.platform.id)
    end

    def combine(user_agent, country)
      return user_agent if country.blank?

      "#{ user_agent } {#{ country }}"
    end

    def should_update?(user, user_agent, country)
      return false if user.blank?
      return false if user_agent.blank?
      return true if user.last_user_agent.blank?

      user.last_user_agent != combine(user_agent, country)
    end

    def append_if_necessary(field, value)
      return if value.blank? || value == 'Unknown'

      string_value = value.to_s
      field << string_value unless field.include?(string_value)
    end
  end
end
