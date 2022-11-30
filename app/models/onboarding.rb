# frozen_string_literal: true

# == Schema Information
#
# Table name: onboardings
#
#  id         :integer          not null, primary key
#  name       :integer          not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  status     :integer          default("pending"), not null
#  step       :integer
#
# Indexes
#
#  index_onboardings_on_status            (status)
#  index_onboardings_on_user_id_and_name  (user_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Onboarding < ApplicationRecord
  belongs_to :user, inverse_of: :onboardings, optional: false

  validates :name, presence: true
  validates :user_id, uniqueness: { scope: :name }

  scope :finished, -> { where(status: %i(dismissed completed)) }

  enum name: {
    chat: 0,
    maker: 1,
    user_signup: 2,
    maker_profile_settings: 3,
    user_onboarding_tasks: 4,
    mobile: 5,
  }

  enum status: {
    pending: 0,
    dismissed: 1,
    completed: 2,
  }
end
