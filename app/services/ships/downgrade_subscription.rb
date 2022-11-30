# frozen_string_literal: true

module Ships::DowngradeSubscription
  extend self

  def call(user)
    if user.ship_subscription.blank?
      ErrorReporting.report_warning_message("User doesn't have a valid Ship subscription", extra: { user_id: user.id })
      return
    end

    ShipSubscription.transaction do
      user.ship_subscription.destroy!

      user.ship_billing_information&.destroy!

      free_ship_subscription = ShipSubscription.create!(
        user: user,
        billing_plan: :free,
        billing_period: :monthly,
        status: :active,
      )

      Ships::DowngradePlan.call(free_ship_subscription)
    end
  end
end
