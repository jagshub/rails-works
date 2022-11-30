# frozen_string_literal: true

# == Schema Information
#
# Table name: ship_tracking_identities
#
#  id           :integer          not null, primary key
#  visitor_id   :string
#  user_id      :integer
#  source       :string
#  campaign     :string
#  medium       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  landing_page :string
#
# Indexes
#
#  index_ship_tracking_identities_on_user_id     (user_id)
#  index_ship_tracking_identities_on_visitor_id  (visitor_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class ShipTrackingIdentity < ApplicationRecord
  belongs_to :user, optional: true

  has_many :events, class_name: 'ShipTrackingEvent', inverse_of: :identity, dependent: :delete_all

  validate :ensure_visitor_id_or_user_id

  private

  def ensure_visitor_id_or_user_id
    errors.add(:base, 'Missing visitor_id or user_id') if visitor_id.blank? && user_id.blank?
  end
end
