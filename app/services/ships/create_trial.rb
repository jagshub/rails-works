# frozen_string_literal: true

class Ships::CreateTrial
  attr_reader :inputs, :user

  class << self
    def call(inputs:, user:)
      new(inputs, user).call
    end
  end

  def initialize(inputs, user)
    @inputs = inputs
    @user = user
  end

  def call
    return user.ship_subscription if user.ship_subscription&.trial?
    raise "User #{ user.id } already has users a trial" if user.ship_user_metadata&.trial_used?
    raise "User #{ user.id } already has a ship subscription" if user.ship_subscription.present?

    subscription = ShipSubscription.new(
      billing_period: inputs[:billing_period],
      billing_plan: inputs[:billing_plan],
      user: user,
    )

    if subscription.free?
      subscription.status = :active
    else
      subscription.status = :trial
      subscription.trial_ends_at = 7.days.from_now
    end

    ShipSubscription.transaction do
      metadata = Ships::UpdateMetadata.call(user, ship_instant_access_page)
      subscription.save!
      subscription.user.ship_lead&.customer!

      account = user.ship_account || ShipAccount.new(user: user)
      account.subscription = subscription
      account.save!

      metadata.update!(trial_used: subscription.trial?)
    end

    Ships::Slack::Subscription.call(ship_subscription: subscription)

    subscription
  end

  private

  def ship_instant_access_page
    @ship_instant_access_page ||= ShipInstantAccessPage.find_by(id: inputs[:ship_instant_access_page_id])
  end
end
