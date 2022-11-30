# frozen_string_literal: true

# == Schema Information
#
# Table name: ship_invite_codes
#
#  id             :integer          not null, primary key
#  discount_value :integer          default(0), not null
#  code           :string           not null
#  image_uuid     :string
#  description    :text             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class ShipInviteCode < ApplicationRecord
  include Uploadable
  include ExplicitCounterCache

  validates :code, presence: true, uniqueness: true
  validates :discount_value, presence: true
  validates :description, presence: true

  has_many :instant_access_pages, class_name: 'ShipInstantAccessPage', dependent: :nullify, inverse_of: :ship_invite_code
  has_many :billing_informations, class_name: 'ShipBillingInformation', dependent: :nullify, inverse_of: :ship_invite_code

  uploadable :image

  def name
    code
  end

  def discount?
    discount_value && discount_value > 0
  end
end
