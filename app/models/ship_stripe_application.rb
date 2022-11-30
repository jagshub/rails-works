# frozen_string_literal: true

# == Schema Information
#
# Table name: ship_stripe_applications
#
#  id              :integer          not null, primary key
#  ship_account_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_ship_stripe_applications_on_ship_account_id  (ship_account_id)
#
# Foreign Keys
#
#  fk_rails_...  (ship_account_id => ship_accounts.id)
#

class ShipStripeApplication < ApplicationRecord
  belongs_to :account, class_name: 'ShipAccount', foreign_key: 'ship_account_id', optional: false, inverse_of: :stripe_application
end
