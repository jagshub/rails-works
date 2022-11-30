# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_plans
#
#  id                  :integer          not null, primary key
#  amount_in_cents     :integer          not null
#  period_in_months    :integer          not null
#  project             :integer          not null
#  stripe_plan_id      :string           not null
#  name                :string           not null
#  description         :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  subscriptions_count :integer          default(0), not null
#  active              :boolean          default(TRUE), not null
#
# Indexes
#
#  index_payment_plans_on_active          (active) WHERE (active IS TRUE)
#  index_payment_plans_on_project         (project)
#  index_payment_plans_on_stripe_plan_id  (stripe_plan_id) UNIQUE
#

class Payment::Plan < ApplicationRecord
  ALLOWED_STRIPE_PLAN_INTERVALS = ['month', 'year'].freeze

  include Namespaceable
  include Payment::HasProject
  include ChronologicalOrder

  has_many :subscriptions, class_name: 'Payment::Subscription', inverse_of: :plan

  has_many :plan_discount_associations, class_name: 'Payment::PlanDiscountAssociation', dependent: :destroy
  has_many :discounts, class_name: 'Payment::Discount', through: :plan_discount_associations, source: :discount

  validates :stripe_plan_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :period_in_months, presence: true
  validates :amount_in_cents, presence: true, numericality: { greater_than: 0 }

  attr_readonly :stripe_plan_id, :project, :amount_in_cents, :period_in_months

  scope :active, -> { where(active: true) }
end
