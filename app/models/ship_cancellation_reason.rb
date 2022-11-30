# frozen_string_literal: true

# == Schema Information
#
# Table name: ship_cancellation_reasons
#
#  id           :integer          not null, primary key
#  reason       :text             not null
#  billing_plan :integer          not null
#  user_id      :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_ship_cancellation_reasons_on_user_id  (user_id)
#

class ShipCancellationReason < ApplicationRecord
  belongs_to :user, optional: false

  validates :reason, presence: true
  validates :billing_plan, presence: true

  enum billing_plan: {
    free: 0,
    pro: 100,
    super_pro: 200,
  }
end
