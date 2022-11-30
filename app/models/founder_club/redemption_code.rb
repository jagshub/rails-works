# frozen_string_literal: true

# == Schema Information
#
# Table name: founder_club_redemption_codes
#
#  id           :integer          not null, primary key
#  deal_id      :integer          not null
#  code         :string
#  kind         :integer          default("disabled"), not null
#  limit        :integer          default(1), not null
#  claims_count :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_founder_club_redemption_codes_on_deal_id_and_code  (deal_id,code) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (deal_id => founder_club_deals.id)
#

class FounderClub::RedemptionCode < ApplicationRecord
  include Namespaceable

  belongs_to :deal, class_name: 'FounderClub::Deal', inverse_of: :claims
  # NOTE(rstankov): Intentionally we don't have dependent, code shouldn't be removed when they have claims
  has_many :claims, class_name: 'FounderClub::Claim', inverse_of: :redemption_code

  attr_readonly :deal_id

  enum kind: %i(disabled limited unlimited)

  scope :within_limit, -> { limited.where(arel_table[:limit].gt(arel_table[:claims_count])) }

  validates :limit, numericality: { greater_than: 0 }
end
