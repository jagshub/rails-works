# frozen_string_literal: true

# == Schema Information
#
# Table name: golden_kitty_sponsors
#
#  id               :bigint(8)        not null, primary key
#  name             :string           not null
#  description      :string           not null
#  url              :string           not null
#  website          :string           not null
#  logo_uuid        :string           not null
#  left_image_uuid  :string
#  right_image_uuid :string
#  dark_ui          :boolean          default(TRUE), not null
#  bg_color         :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class GoldenKitty::Sponsor < ApplicationRecord
  include Namespaceable
  include Uploadable

  uploadable :logo
  uploadable :right_image
  uploadable :left_image

  validates :name, :description, :url, :website, :logo_uuid, presence: true

  has_many :edition_associations, class_name: '::GoldenKitty::EditionSponsor', inverse_of: :sponsor, dependent: :destroy
  has_many :editions, through: :golden_kitty_edition_sponsors
  has_many :golden_kitty_categories, class_name: '::GoldenKitty::Category', inverse_of: :golden_kitty_sponsor
end
