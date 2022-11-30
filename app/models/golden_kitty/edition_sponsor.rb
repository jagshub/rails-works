# frozen_string_literal: true

# == Schema Information
#
# Table name: golden_kitty_edition_sponsors
#
#  id         :bigint(8)        not null, primary key
#  edition_id :bigint(8)        not null
#  sponsor_id :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_gk_edition_sponsors_on_edition_id_and_sponsor_id  (edition_id,sponsor_id) UNIQUE
#  index_golden_kitty_edition_sponsors_on_sponsor_id       (sponsor_id)
#
# Foreign Keys
#
#  fk_rails_...  (edition_id => golden_kitty_editions.id)
#  fk_rails_...  (sponsor_id => golden_kitty_sponsors.id)
#

class GoldenKitty::EditionSponsor < ApplicationRecord
  include Namespaceable

  belongs_to :edition, class_name: '::GoldenKitty::Edition', inverse_of: :sponsor_associations, optional: false
  belongs_to :sponsor, class_name: '::GoldenKitty::Sponsor', inverse_of: :edition_associations, optional: false

  validates :edition_id, presence: true
  validates :sponsor_id, presence: true, uniqueness: { scope: :edition_id }
end
