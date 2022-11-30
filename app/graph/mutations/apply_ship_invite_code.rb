# frozen_string_literal: true

module Graph::Mutations
  class ApplyShipInviteCode < BaseMutation
    argument_record :ship_instant_access_page, ShipInstantAccessPage

    require_current_user

    def perform(ship_instant_access_page:)
      return if current_user.ship_subscription&.premium?

      Ships::UpdateMetadata.call(current_user, ship_instant_access_page)
      nil
    end
  end
end
