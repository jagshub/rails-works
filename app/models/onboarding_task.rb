# frozen_string_literal: true

# == Schema Information
#
# Table name: onboarding_tasks
#
#  id           :bigint(8)        not null, primary key
#  task         :string           not null
#  user_id      :bigint(8)        not null
#  completed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_onboarding_tasks_on_user_id_and_task  (user_id,task) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class OnboardingTask < ApplicationRecord
  belongs_to :user, inverse_of: :onboarding_tasks, optional: false

  validates :task, presence: true
  validates :user_id, uniqueness: { scope: :task }

  scope :completed, -> { where.not(completed_at: nil) }

  enum task: {
    complete_profile: 'complete_profile',
    follow_topics: 'follow_topics',
    upvote_products: 'upvote_products',
    post_comment: 'post_comment',
  }
end
