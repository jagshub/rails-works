# frozen_string_literal: true

# == Schema Information
#
# Table name: ship_subscriptions
#
#  id                     :integer          not null, primary key
#  status                 :integer          not null
#  billing_plan           :integer          not null
#  billing_period         :integer          not null
#  user_id                :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  stripe_subscription_id :string
#  ends_at                :datetime
#  cancelled_at           :datetime
#  trial_ends_at          :datetime
#
# Indexes
#
#  index_ship_subscriptions_on_user_id_and_status  (user_id,status)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class ShipSubscription < ApplicationRecord
  belongs_to :user, inverse_of: :ship_subscription
  has_one :ship_billing_information, through: :user
  has_one :account, class_name: 'ShipAccount', inverse_of: :subscription, dependent: :nullify

  validates :status, presence: true
  validates :billing_plan, presence: true
  validates :billing_period, presence: true

  scope :by_created_at, -> { order('created_at DESC') }
  scope :premium, -> { where.not(billing_plan: 0) }
  scope :cancelled, -> { where.not(cancelled_at: nil) }
  scope :ended, -> { where('cancelled_at < NOW() AND ends_at < NOW()') }
  scope :ended_trial, -> { trial.where('trial_ends_at < NOW() ') }

  enum status: {
    free_access: 100,
    trial: 110,
    active: 200,
  }

  enum billing_plan: {
    free: 0,
    pro: 100,
    super_pro: 200,
  }

  enum billing_period: {
    annual: 100,
    monthly: 200,
  }

  def cancelled?
    cancelled_at.present?
  end

  def trial_ended?
    trial? && trial_ends_at.past?
  end

  def ended?
    (ends_at? && ends_at.past?) || trial_ended?
  end

  def premium?
    pro? || super_pro?
  end
end
