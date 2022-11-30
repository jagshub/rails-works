# frozen_string_literal: true

# == Schema Information
#
# Table name: ship_billing_informations
#
#  id                  :integer          not null, primary key
#  stripe_customer_id  :string           not null
#  stripe_token_id     :string
#  billing_email       :string
#  user_id             :integer          not null
#  ship_invite_code_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_ship_billing_informations_on_stripe_customer_id  (stripe_customer_id) UNIQUE
#  index_ship_billing_informations_on_stripe_token_id     (stripe_token_id) UNIQUE
#  index_ship_billing_informations_on_user_id             (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class ShipBillingInformation < ApplicationRecord
  belongs_to :user
  belongs_to :ship_invite_code, optional: true, inverse_of: :billing_informations

  validates :user_id, uniqueness: true
  validates :stripe_token_id, uniqueness: true, presence: true
  validates :stripe_customer_id, uniqueness: true, presence: true
  validates :billing_email, presence: true

  delegate :discount_value, to: :ship_invite_code, allow_nil: true
end
