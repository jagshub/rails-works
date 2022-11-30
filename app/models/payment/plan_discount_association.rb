# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_plan_discount_associations
#
#  id          :integer          not null, primary key
#  plan_id     :integer
#  discount_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_payment_plan_discount_associations_on_discount_id  (discount_id)
#  index_payment_plan_discount_associations_on_plan_id      (plan_id)
#
# Foreign Keys
#
#  fk_rails_...  (discount_id => payment_discounts.id)
#  fk_rails_...  (plan_id => payment_plans.id)
#

class Payment::PlanDiscountAssociation < ApplicationRecord
  include Namespaceable

  belongs_to :plan, class_name: 'Payment::Plan', inverse_of: :plan_discount_associations
  belongs_to :discount, class_name: 'Payment::Discount', inverse_of: :plan_discount_associations
end
