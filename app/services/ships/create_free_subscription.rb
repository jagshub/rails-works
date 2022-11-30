# frozen_string_literal: true

module Ships::CreateFreeSubscription
  extend self

  def call(user)
    raise "User #{ user.id } already has a ship subscription" if user.ship_subscription.present?

    subscription = ShipSubscription.new(
      billing_period: :annual,
      billing_plan: :free,
      status: :active,
      user: user,
    )

    ShipSubscription.transaction do
      subscription.save!

      account = user.ship_account || user.build_ship_account
      account.update! subscription: subscription

      Ships::UpdateMetadata.call(user)
    end

    Ships::Slack::Subscription.call(ship_subscription: subscription)

    subscription
  end
end
