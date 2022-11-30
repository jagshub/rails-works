# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_discounts
#
#  id                  :integer          not null, primary key
#  active              :boolean          default(FALSE), not null
#  percentage_off      :integer          not null
#  name                :string           not null
#  stripe_coupon_code  :string           not null
#  code                :string           not null
#  description         :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  subscriptions_count :integer          default(0), not null
#
# Indexes
#
#  index_payment_discounts_on_active              (active) WHERE (active IS TRUE)
#  index_payment_discounts_on_code                (code) UNIQUE
#  index_payment_discounts_on_stripe_coupon_code  (stripe_coupon_code) UNIQUE
#

class Payment::Discount < ApplicationRecord
  include Namespaceable
  include ChronologicalOrder

  has_many :subscriptions, class_name: 'Payment::Subscription', inverse_of: :discount

  has_many :plan_discount_associations, class_name: 'Payment::PlanDiscountAssociation', dependent: :destroy
  has_many :plans, class_name: 'Payment::Plan', through: :plan_discount_associations, source: :plan

  has_many :access_requests, class_name: 'FounderClub::AccessRequest', dependent: :destroy

  validates :code, presence: true, uniqueness: true
  validates :stripe_coupon_code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :percentage_off, numericality: { greater_than: 0, less_than: 101 }

  attr_readonly :percentage_off, :stripe_coupon_code

  scope :active, -> { where(active: true) }
end
