# frozen_string_literal: true

module Payments::HandleError
  extend self

  STRIPE_ERROR = 'Stripe error'
  CARD_ERROR = 'Card rejected by Stripe'
  OTHER_ERROR = 'Internal system error'
  INVALID_PLAN_ERROR = 'Invalid payment plan'
  ACTIVE_SUBSCRIPTION_IN_PROJECT_ERROR = 'You already have active subscription'
  MULTIPLE_ACTIVE_SUBSCRIPTIONS_FOR_PLAN_ERROR = 'You have multiple active subscriptions for this plan'
  INVALID_SUBSCRIPTION_ID_ERROR = 'Invalid subscription id'

  def call(current_user_id: nil)
    extra = { current_user_id: current_user_id }
    yield
  rescue ::Payments::Errors::InvalidPlanError => e
    ErrorReporting.report_error(e, extra: extra)
    Error.new(INVALID_PLAN_ERROR)
  rescue ::Payments::Errors::InvalidSubscriptionIdError => e
    ErrorReporting.report_error(e, extra: extra)
    Error.new(INVALID_SUBSCRIPTION_ID_ERROR)
  rescue ::Payments::Errors::HasActiveSubscriptionInProjectError => e
    ErrorReporting.report_error(e, extra: extra)
    Error.new(ACTIVE_SUBSCRIPTION_IN_PROJECT_ERROR)
  rescue ::Payments::Errors::MultipleActiveSubscriptionsForPlanError => e
    ErrorReporting.report_error(e, extra: extra)
    Error.new(MULTIPLE_ACTIVE_SUBSCRIPTIONS_FOR_PLAN_ERROR)
  rescue Stripe::CardError => e
    ErrorReporting.report_error(e, extra: extra.merge(stripe_error: card_error_info(e)))
    Error.new(e.message)
  rescue Stripe::StripeError => e
    ErrorReporting.report_error(e, extra: extra)
    Error.new(STRIPE_ERROR)
  rescue StandardError => e
    p e.message if Rails.env.test? # rubocop:disable Rails/Output
    ErrorReporting.report_error(e, extra: extra)
    Error.new(OTHER_ERROR)
  end

  private

  def card_error_info(e)
    error = (e.json_body && e.json_body[:error]) || {}

    {
      type: error[:type],
      charge: error[:charge],
      code: error[:code],
      decline_code: error[:decline_code],
      param: error[:param],
      message: error[:message],
    }.compact
  end

  class Error
    include ActiveModel::Validations

    def initialize(message)
      errors.add :base, message
    end
  end
end
