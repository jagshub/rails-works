# frozen_string_literal: true

module UpcomingPages
  class InstantAccess
    class << self
      def call(ship_instant_access_page, user)
        metadata = ShipUserMetadata.find_or_initialize_by(user_id: user.id)
        metadata.ship_instant_access_page = ship_instant_access_page
        metadata.save!

        ShipSubscription.create!(
          billing_period: :monthly,
          billing_plan: :free,
          user: user,
          status: :active,
        )
      end
    end
  end
end
