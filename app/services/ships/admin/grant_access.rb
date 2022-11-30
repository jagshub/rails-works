# frozen_string_literal: true

class Ships::Admin::GrantAccess
  attr_reader :user, :moderator

  class << self
    def call(user, moderator, billing_plan)
      new(user, moderator, billing_plan).call
    end
  end

  def initialize(user, moderator, billing_plan)
    @user = user
    @moderator = moderator
    @billing_plan = billing_plan
  end

  def call
    return false if user.ship_subscription.present?

    status = @billing_plan.to_sym == :free ? :active : :free_access

    subscription = ShipSubscription.create!(
      user: user,
      billing_plan: @billing_plan,
      billing_period: :monthly,
      status: status,
    )

    create_or_update_ship_account(subscription)

    ModerationLog.create!(
      reference: user,
      moderator: moderator,
      message: "Ship trial for #{ @billing_plan } granted",
    )

    true
  end

  def create_or_update_ship_account(subscription)
    account = subscription.user.ship_account || ShipAccount.new(user: subscription.user)
    account.subscription = subscription
    account.save!
  end
end
