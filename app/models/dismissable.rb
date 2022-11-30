# frozen_string_literal: true

# == Schema Information
#
# Table name: dismissables
#
#  id                :integer          not null, primary key
#  dismissable_group :string           not null
#  dismissable_key   :string           not null
#  user_id           :integer          not null
#  dismissed_at      :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_dismissables_on_dismissable_group_and_user_id  (dismissable_group,user_id)
#

class Dismissable < ApplicationRecord
  belongs_to :user

  validates :dismissable_group, presence: true
  validates :dismissable_key, presence: true
  validates :dismissed_at, presence: true

  class << self
    def dismissed_by(user:, dismissable_group:)
      return none if user.blank?

      where(dismissable_group: dismissable_group, user_id: user.id)
        .where('dismissed_at > :some_time_ago', some_time_ago: 7.days.ago)
        .pluck('dismissable_key')
    end

    def dismiss!(user:, dismissable_group:, dismissable_key:)
      return if user.blank?

      find_or_initialize_by(user_id: user.id, dismissable_group: dismissable_group, dismissable_key: dismissable_key)
        .update!(dismissed_at: Time.current)
    end
  end
end
