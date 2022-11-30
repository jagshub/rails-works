# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_subscriptions
#
#  id                      :integer          not null, primary key
#  project                 :integer          not null
#  plan_amount_in_cents    :integer          not null
#  stripe_customer_id      :string           not null
#  stripe_subscription_id  :string           not null
#  stripe_coupon_code      :string
#  cancellation_reason     :string
#  user_canceled_at        :datetime
#  stripe_canceled_at      :datetime
#  expired_at              :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :integer          not null
#  plan_id                 :integer          not null
#  discount_id             :integer
#  renew_notice_sent_at    :datetime
#  stripe_refund_id        :string
#  refund_reason           :string
#  refunded_at             :datetime
#  charged_amount_in_cents :integer          not null
#  marketing_campaign_name :string
#
# Indexes
#
#  index_payment_subscriptions_on_discount_id                       (discount_id)
#  index_payment_subscriptions_on_plan_id                           (plan_id)
#  index_payment_subscriptions_on_project                           (project)
#  index_payment_subscriptions_on_user_id                           (user_id)
#  index_payment_subscriptions_project_user_expired_at_refunded_at  (project,user_id,expired_at,refunded_at) WHERE ((expired_at IS NULL) AND (refunded_at IS NULL))
#  index_payment_subscriptions_stripe_customer_id_subscription_id   (stripe_customer_id,stripe_subscription_id)
#
# Foreign Keys
#
#  fk_rails_...  (discount_id => payment_discounts.id)
#  fk_rails_...  (plan_id => payment_plans.id)
#  fk_rails_...  (user_id => users.id)
#

class Payment::Subscription < ApplicationRecord
  include Namespaceable
  include ChronologicalOrder
  include Payment::HasProject

  HasTimeAsFlag.define self, :expired, enable: :expire
  HasTimeAsFlag.define self, :refunded

  belongs_to :user, inverse_of: :payment_subscriptions
  belongs_to :plan, class_name: 'Payment::Plan', counter_cache: true, inverse_of: :subscriptions
  belongs_to :discount, class_name: 'Payment::Discount', counter_cache: true, inverse_of: :subscriptions, optional: true

  delegate :percentage_off, to: :discount, allow_nil: true

  validates :stripe_subscription_id, presence: true
  validates :stripe_customer_id, presence: true
  validates :plan_amount_in_cents, presence: true
  validate :project_should_be_same_as_plan_project, on: :create
  validate :subscription_should_have_stripe_refund_id_if_being_refunded

  attr_readonly :stripe_subscription_id, :stripe_customer_id, :plan_amount_in_cents, :stripe_coupon_code, :project

  scope :active, -> { where(expired_at: nil, refunded_at: nil) }
  scope :active_for_user_in_plan, ->(user:, plan:) { active.where(user_id: user, plan: plan) }
  scope :active_for_user_in_project, ->(user:, project:) { active.from_project(project).where(user_id: user) }
  scope :canceled, -> { where.not(user_canceled_at: nil) }
  scope :not_canceled, -> { active.where(user_canceled_at: nil) }

  def refund?
    !expired? && !refunded? && stripe_refund_id.nil?
  end

  def canceled?
    user_canceled_at.present?
  end

  def ended_on
    expired_at || stripe_canceled_at
  end

  # NOTE(dhruvparmar372): A subscription is active only if
  # 1. it has not expired as a result of either 'customer.subscription.deleted'
  #    or 'charge.refunded' event from Stripe.
  # 2. refund has not been initiated for it from admin panel.
  # The above logic reflects for :active scope above as well.
  def active?
    !expired? && !refunded?
  end

  private

  def project_should_be_same_as_plan_project
    errors.add(:project, "can't be different from plan's project") unless project == plan.project
  end

  def subscription_should_have_stripe_refund_id_if_being_refunded
    errors.add(:refund, 'cannot be done as stripe_refund_id is not present') if refunded? && stripe_refund_id.nil?
  end
end
