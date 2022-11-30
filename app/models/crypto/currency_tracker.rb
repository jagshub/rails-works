# frozen_string_literal: true

# == Schema Information
#
# Table name: crypto_currency_trackers
#
#  id           :bigint(8)        not null, primary key
#  token_id     :integer          not null
#  token_symbol :string           not null
#  token_name   :string           not null
#  usd_price    :decimal(12, 2)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_crypto_currency_trackers_on_token_id  (token_id)
#
class Crypto::CurrencyTracker < ApplicationRecord
  include Namespaceable

  validates :token_id, presence: true
  validates :token_symbol, presence: true
  validates :token_name, presence: true
  validates :usd_price, presence: true, numericality: { greater_than: 0 }

  MIN_COOLDOWN = 45.minutes

  def self.can_refresh?(token_id)
    last_created_at = Crypto::CurrencyTracker.where(token_id: token_id).maximum(:created_at)
    return true if last_created_at.nil?

    last_created_at < MIN_COOLDOWN.ago
  end
end
