# frozen_string_literal: true

module Jobs::Plans
  extend self

  Plan = Struct.new(:id, :sku, :monthly_price, :multiplier, :description, :term)

  PLANS = [
    Plan.new('1', ENV['JOBS_STRIPE_SKU_1'], 299, 1, 'Month-to-month', '1 month'),
    Plan.new('3', ENV['JOBS_STRIPE_SKU_3'], 199, 3, '3 months prepayment', '3 months'),
  ].freeze

  def plans
    PLANS
  end

  def exists?(id)
    id = id.to_s

    PLANS.find { |plan| plan.id == id }.present?
  end

  def find_by_id(id)
    id = id.to_s

    found = PLANS.find { |plan| plan.id == id }
    raise ArgumentError, "Invalid plan for id '#{ id }'" if found.blank?

    found
  end
end
