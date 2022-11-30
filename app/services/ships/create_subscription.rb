# frozen_string_literal: true

class Ships::CreateSubscription
  attr_reader :inputs, :current_user, :previous_subscription

  UPGRADE_ROLES = ['user'].freeze

  class << self
    def call(inputs:, current_user:)
      new(inputs, current_user).call
    end
  end

  def initialize(inputs, current_user)
    @inputs = inputs
    @current_user = current_user
    @previous_subscription = current_user.ship_subscription
  end

  def call
    return previous_subscription if identical_subscriptions?

    ShipBillingInformation.transaction do
      subscription.save!
      create_or_update_billing_info
      create_or_update_ship_account
      create_or_update_metadata
      cancel_previous_subscriptions
      update_ship_lead
      downgrade_upcoming_pages
      track_event

      # NOTE(vesln): the Stripe call should always be last
      create_subscription_in_stripe
    end

    send_stripe_discounts

    mark_trial_as_used

    upgrade_user_role

    Ships::Slack::Subscription.call(ship_subscription: subscription, previous_ship_subscription: previous_subscription)

    subscription
  end

  private

  def identical_subscriptions?
    return false if previous_subscription.blank?
    return false if previous_subscription.trial?
    return false if previous_subscription.ended?
    return false if previous_subscription.cancelled?

    previous_subscription.billing_plan == inputs[:billing_plan] && previous_subscription.billing_period == inputs[:billing_period]
  end

  def create_or_update_ship_account
    @account = current_user.ship_account || ShipAccount.new(user: current_user)
    @account.subscription = subscription
    @account.save!
  end

  def create_subscription_in_stripe
    return if subscription.ship_billing_information.nil?

    Ships::Payments::Subscription.create_or_update!(subscription)
  end

  def create_or_update_metadata
    Ships::UpdateMetadata.call(current_user)
  end

  def mark_trial_as_used
    metadata = ShipUserMetadata.find_or_initialize_by(user_id: current_user.id)
    metadata.update(trial_used: true)
  end

  def create_or_update_billing_info
    billing_info = ShipBillingInformation.find_by(user: current_user)

    if billing_info.present?
      billing_info.update!(ship_invite_code: ship_invite_code) if ship_invite_code.present? && billing_info.ship_invite_code.blank?
    elsif !subscription.free?
      create_billing_info
    end
  end

  def subscription
    @ship_subscription ||= ShipSubscription.new(
      billing_period: inputs[:billing_period].to_sym,
      billing_plan: inputs[:billing_plan].to_sym,
      status: :active,
      user: current_user,
    )
  end

  def create_billing_info
    billing_email = inputs[:billing_email].try(:downcase)

    customer = External::StripeApi.create_customer(
      stripe_token_id: inputs[:stripe_token_id],
      email: billing_email,
      description: current_user.id,
      extra: inputs[:extra],
    )

    ShipBillingInformation.create!(
      user: current_user,
      stripe_customer_id: customer.id,
      stripe_token_id: inputs[:stripe_token_id],
      ship_invite_code: ship_invite_code,
      billing_email: billing_email,
    )
  end

  def update_ship_lead
    subscription.user.ship_lead&.customer!
  end

  def upgrade_user_role
    return if subscription.free?
    return unless UPGRADE_ROLES.include? subscription.user.role

    subscription.user.update! role: User.roles[:can_post]
  end

  def cancel_previous_subscriptions
    ShipSubscription.where(user: current_user).where.not(id: subscription.id).destroy_all
  end

  def downgrade_upcoming_pages
    Ships::DowngradePlan.call(subscription)
  end

  def ship_invite_code
    @ship_invite_code ||= Ships::InviteCode.call(current_user)
  end

  def track_event
    if transition_from_trial?
      Ships::Tracking.record(
        user: current_user,
        funnel_step: Ships::Tracking::TRIAL,
        event_name: subscription.free? ? Ships::Tracking::DOWNGRADE : Ships::Tracking::UPGRADE,
        meta: {
          billing_period: subscription.billing_period,
          billing_plan: subscription.billing_plan,
          previous_billing_period: previous_subscription&.billing_period,
          previous_billing_plan: previous_subscription&.billing_plan,
        },
      )
    end

    Ships::Tracking.record(
      user: current_user,
      funnel_step: subscription.free? && !transition_from_trial? ? Ships::Tracking::CANCEL : Ships::Tracking::SUBSCRIPTION,
      meta: {
        trial: transition_from_trial?,
        billing_period: subscription.billing_period,
        billing_plan: subscription.billing_plan,
        previous_billing_period: previous_subscription&.billing_period,
        previous_billing_plan: previous_subscription&.billing_plan,
      },
    )
  end

  def transition_from_trial?
    previous_subscription&.trial?
  end

  def send_stripe_discounts
    return if @account.trial?
    return unless transition_from_trial?
    return unless current_user.ship_lead&.request_stripe_atlas?
    return unless current_user.send_stripe_discount_email

    Ships::StripeDiscountCode.deliver_to(@account)
  end
end
