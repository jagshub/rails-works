# frozen_string_literal: true

class Ships::Admin::UpdateInviteCode
  attr_reader :user, :moderator, :ship_invite_code

  class << self
    def call(user, moderator, ship_invite_code)
      new(user, moderator, ship_invite_code).call
    end
  end

  def initialize(user, moderator, ship_invite_code)
    @user = user
    @moderator = moderator
    @ship_invite_code = ship_invite_code
  end

  def call
    return false if user.ship_subscription.blank?

    ShipSubscription.transaction do
      user.ship_billing_information.update!(ship_invite_code: ship_invite_code)

      Ships::Payments::Subscription.update_coupon!(user.ship_subscription)

      ModerationLog.create!(
        reference: user,
        moderator: moderator,
        message: ship_invite_code.present? ? "Changed invite code to #{ ship_invite_code.code }" : 'Removed the invite code',
      )
    end

    true
  end
end
