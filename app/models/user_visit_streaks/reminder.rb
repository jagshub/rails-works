# frozen_string_literal: true

# == Schema Information
#
# Table name: user_visit_streak_reminders
#
#  id              :bigint(8)        not null, primary key
#  user_id         :bigint(8)        not null
#  streak_duration :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_user_visit_streak_reminders_on_user_id  (user_id)
#
class UserVisitStreaks::Reminder < ApplicationRecord
  self.table_name = 'user_visit_streak_reminders'

  belongs_to :user, inverse_of: :user_visit_streak_reminders
end
