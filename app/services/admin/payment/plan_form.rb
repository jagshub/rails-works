# frozen_string_literal: true

class Admin::Payment::PlanForm
  include MiniForm::Model

  STRIPE_PLAN_NOT_PRESENT_ERROR = 'Plan does not exist in Stripe'
  STRIPE_PLAN_NOT_ACTIVE_ERROR = 'Plan should be active in Stripe'
  STRIPE_PLAN_INVALID_INTERVAL_ERROR = 'Plan should have monthly or annual charge cycle'
  STRIPE_PLAN_ERROR = 'Syncing with plan on Stripe failed'

  ATTRIBUTES = %i(active amount_in_cents period_in_months project stripe_plan_id name description).freeze

  model :payment_plan, attributes: ATTRIBUTES, save: true

  attributes :discount_ids

  delegate :id, :persisted?, :new_record?, to: :payment_plan

  before_validation :sync_with_stripe_plan

  def initialize(payment_plan = ::Payment::Plan.new)
    @payment_plan = payment_plan
  end

  def discount_ids
    @discount_ids || payment_plan&.discount_ids
  end

  def discount_ids=(values)
    @discount_ids = values.reject(&:blank?)
  end

  def to_model
    payment_plan
  end

  def to_param
    id
  end

  private

  def perform
    payment_plan.discount_ids = @discount_ids || []
  end

  def sync_with_stripe_plan
    return unless stripe_plan_id

    stripe_plan = External::StripeApi.fetch_plan(stripe_plan_id)
    validate_stripe_plan(stripe_plan)
    return unless errors.empty?

    self.amount_in_cents = stripe_plan.amount
    self.period_in_months = get_period_from_stripe_plan(stripe_plan)
  rescue StandardError => e
    ErrorReporting.report_error(e)
    errors.add(:stripe_plan, STRIPE_PLAN_ERROR)
  end

  def validate_stripe_plan(stripe_plan)
    return errors.add(:stripe_plan, STRIPE_PLAN_NOT_PRESENT_ERROR) if stripe_plan.nil?
    return errors.add(:stripe_plan, STRIPE_PLAN_NOT_ACTIVE_ERROR) unless stripe_plan&.active
    return errors.add(:stripe_plan, STRIPE_PLAN_INVALID_INTERVAL_ERROR) unless Payment::Plan::ALLOWED_STRIPE_PLAN_INTERVALS.include?(stripe_plan&.interval)
  end

  def get_period_from_stripe_plan(stripe_plan)
    # Note(dhruvparmar372): For now assumes only yearly or monthly plans would
    # be created in Stripe. Will need to adjust to 'week' or 'daily'
    # pricing intervals on Stripe.
    stripe_plan.interval_count * (stripe_plan.interval == 'year' ? 12 : 1)
  end
end
