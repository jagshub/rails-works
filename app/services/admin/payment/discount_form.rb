# frozen_string_literal: true

class Admin::Payment::DiscountForm
  include MiniForm::Model

  STRIPE_COUPON_ERROR = 'Creating coupon on Stripe failed'
  CHOOSE_PAYMENT_PLAN_ERROR = 'Please choose atleast one payment plan'
  DISCOUNT_ATTRIBUTES = %i(percentage_off name description active stripe_coupon_code code).freeze

  model :payment_discount, attributes: DISCOUNT_ATTRIBUTES, save: true

  attributes :plan_ids

  delegate :id, :persisted?, :new_record?, to: :payment_discount

  before_validation :create_discount_on_stripe

  validates :plan_ids, length: { minimum: 1, message: CHOOSE_PAYMENT_PLAN_ERROR }

  def initialize(payment_discount = ::Payment::Discount.new)
    @payment_discount = payment_discount
  end

  def plan_ids
    @plan_ids || payment_discount&.plan_ids
  end

  def plan_ids=(values)
    @plan_ids = values.reject(&:blank?)
  end

  def to_model
    payment_discount
  end

  def to_param
    id
  end

  private

  def perform
    payment_discount.plan_ids = @plan_ids if @plan_ids
  end

  def create_discount_on_stripe
    return unless name && percentage_off && stripe_coupon_code.nil? && @plan_ids.present?

    code = SecureRandom.base64(10).delete('=').delete("\n")[0..6]
    coupon_code = "#{ name.parameterize.underscore }_#{ code }"
    External::StripeApi.create_coupon(
      code: coupon_code,
      name: name,
      percent_off: percentage_off,
    )
    self.stripe_coupon_code = coupon_code
  rescue StandardError => e
    ErrorReporting.report_error(e)
    errors.add :network, STRIPE_COUPON_ERROR
  end
end
