# frozen_string_literal: true

# == Schema Information
#
# Table name: visit_streaks
#
#  id                    :bigint(8)        not null, primary key
#  user_id               :bigint(8)        not null
#  started_at            :datetime         not null
#  ended_at              :datetime
#  last_visit_at         :datetime         not null
#  duration              :integer          default(1), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  last_web_visit_at     :datetime
#  last_ios_visit_at     :datetime
#  last_android_visit_at :datetime
#
# Indexes
#
#  index_visit_streaks_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class VisitStreak < ApplicationRecord
  belongs_to :user, inverse_of: :visit_streaks

  scope :current, -> { where(ended_at: nil) }
end
