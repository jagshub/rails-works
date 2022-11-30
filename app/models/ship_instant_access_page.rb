# frozen_string_literal: true

# == Schema Information
#
# Table name: ship_instant_access_pages
#
#  id                  :integer          not null, primary key
#  name                :string           not null
#  slug                :string           not null
#  text                :text
#  ship_invite_code_id :integer
#  trashed_at          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  billing_periods     :integer          default("all")
#
# Indexes
#
#  index_ship_instant_access_pages_on_ship_invite_code_id  (ship_invite_code_id)
#
# Foreign Keys
#
#  fk_rails_...  (ship_invite_code_id => ship_invite_codes.id)
#

class ShipInstantAccessPage < ApplicationRecord
  include Sluggable
  include Trashable
  sluggable

  validates :name, presence: true
  belongs_to :ship_invite_code, optional: true, inverse_of: :instant_access_pages

  enum billing_periods: {
    all: 0,
    annual: 100,
  }, _prefix: :billing_period

  delegate :discount_value, to: :ship_invite_code, allow_nil: true

  def sluggable_candidates
    [:slug, :name, %i(name sluggable_sequence)]
  end
end
