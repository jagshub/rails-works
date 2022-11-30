# frozen_string_literal: true

# == Schema Information
#
# Table name: jobs_discount_pages
#
#  id                :integer          not null, primary key
#  name              :string           not null
#  text              :text             not null
#  slug              :string
#  discount_value    :integer          default(0), not null
#  discount_plan_ids :string           default([]), not null, is an Array
#  jobs_count        :integer          default(0), not null
#  trashed_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_jobs_discount_pages_on_slug  (slug) UNIQUE
#

class Jobs::DiscountPage < ApplicationRecord
  include Namespaceable
  include Trashable

  has_many :jobs, foreign_key: 'jobs_discount_page_id', inverse_of: :discount_page, dependent: :nullify

  validates :name, presence: true
  validates :discount_value, numericality: { greater_than: 0, less_than: 100 }
  validates :discount_plan_ids, length: { minimum: 1, message: 'Select at least one plan' }
  validates :slug, presence: true, uniqueness: true

  before_validation :build_slug
  before_validation :clear_plans

  def self.discount_value_for(page, plan)
    return 0 unless page
    return 0 unless page.discount_plan_ids.include?(plan.id)

    page.discount_value
  end

  def stripe_coupon_code
    'JOB-' + Base64.encode64("#{ id }-#{ created_at.to_i.to_s.reverse }"[0..6]).delete('=').delete("\n")
  end

  private

  def clear_plans
    self.discount_plan_ids = discount_plan_ids.to_a.select do |plan_id|
      Jobs::Plans.exists?(plan_id)
    end
  end

  def build_slug
    self.slug = name.to_s.parameterize if slug.blank?
  end
end
