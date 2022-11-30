# frozen_string_literal: true

# == Schema Information
#
# Table name: onboarding_reasons
#
#  id         :bigint(8)        not null, primary key
#  reason     :string           not null
#  user_id    :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_onboarding_reasons_on_user_id_and_reason  (user_id,reason) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class OnboardingReason < ApplicationRecord
  belongs_to :user, inverse_of: :onboarding_reasons, optional: false

  validates :reason, presence: true
  validates :user_id, uniqueness: { scope: :reason }

  enum reason: {
    discover_products: 'discover_products',
    share_products: 'share_products',
    not_sure: 'not_sure',
  }
end
