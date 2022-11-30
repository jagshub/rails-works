# frozen_string_literal: true

module Ships::InviteCode
  extend self

  def call(user)
    billing_info = ShipBillingInformation.find_by(user: user)
    metadata = ShipUserMetadata.find_by(user: user)

    billing_info&.ship_invite_code || metadata&.ship_invite_code
  end
end
