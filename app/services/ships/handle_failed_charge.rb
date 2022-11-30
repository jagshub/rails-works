# frozen_string_literal: true

class Ships::HandleFailedCharge
  REASON = 'Failed Charge (Stripe API)'
  attr_reader :user

  class << self
    def call(user)
      new(user).call
    end
  end

  def initialize(user)
    @user = user
  end

  def call
    return if user.blank?
    return unless user.ship_pro?

    Ships::CancelSubscription.call(user: user, moderator: moderator, reason: REASON, at_period_end: false)
    ShipMailer.subscription_downgraded(user.ship_account).deliver_later
  end

  private

  def moderator
    @moderator ||= ProductHunt.user
  end
end
