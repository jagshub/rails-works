# frozen_string_literal: true

# == Schema Information
#
# Table name: ship_tracking_events
#
#  id                        :integer          not null, primary key
#  ship_tracking_identity_id :integer          not null
#  funnel_step               :string           not null
#  event_name                :string           not null
#  meta                      :jsonb            not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_ship_tracking_events_on_funnel_step                (funnel_step)
#  index_ship_tracking_events_on_ship_tracking_identity_id  (ship_tracking_identity_id)
#
# Foreign Keys
#
#  fk_rails_...  (ship_tracking_identity_id => ship_tracking_identities.id)
#

class ShipTrackingEvent < ApplicationRecord
  belongs_to :identity, class_name: 'ShipTrackingIdentity', foreign_key: 'ship_tracking_identity_id', inverse_of: :events

  validates :funnel_step, presence: true
  validates :event_name, presence: true
end
