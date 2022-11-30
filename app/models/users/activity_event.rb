# frozen_string_literal: true

# == Schema Information
#
# Table name: user_activity_events
#
#  id           :bigint(8)        not null, primary key
#  user_id      :bigint(8)        not null
#  subject_type :string           not null
#  subject_id   :bigint(8)        not null
#  occurred_at  :datetime         not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_user_activities_unique           (user_id,subject_type,subject_id) UNIQUE
#  index_user_activity_events_on_subject  (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Users::ActivityEvent < ApplicationRecord
  self.table_name = 'user_activity_events'

  SUBJECTS = [
    Review,
    Comment,
    Discussion::Thread,
  ].freeze

  belongs_to :user, inverse_of: :activity_events, counter_cache: :activity_events_count
  belongs_to_polymorphic :subject, allowed_classes: SUBJECTS

  validates :user, :subject, :occurred_at, presence: true
end
