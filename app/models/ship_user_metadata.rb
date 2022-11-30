# frozen_string_literal: true

# == Schema Information
#
# Table name: ship_user_metadata
#
#  id                          :integer          not null, primary key
#  ship_instant_access_page_id :integer
#  user_id                     :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  initial_role                :integer
#  trial_used                  :boolean          default(FALSE), not null
#
# Indexes
#
#  index_ship_user_metadata_on_ship_instant_access_page_id  (ship_instant_access_page_id)
#  index_ship_user_metadata_on_user_id                      (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (ship_instant_access_page_id => ship_instant_access_pages.id)
#  fk_rails_...  (user_id => users.id)
#

class ShipUserMetadata < ApplicationRecord
  belongs_to :user
  belongs_to :ship_instant_access_page, optional: true

  delegate :ship_invite_code, to: :ship_instant_access_page, allow_nil: true

  validates :user_id, uniqueness: true

  enum initial_role: User::ROLES
end
