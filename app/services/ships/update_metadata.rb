# frozen_string_literal: true

module Ships::UpdateMetadata
  extend self

  def call(user, ship_instant_access_page = nil)
    metadata = ShipUserMetadata.find_or_initialize_by(user_id: user.id)
    metadata.initial_role = metadata.initial_role.presence || user.role
    metadata.ship_instant_access_page = ship_instant_access_page if ship_instant_access_page.present?
    metadata.save!
    metadata
  end
end
