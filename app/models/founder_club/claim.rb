# frozen_string_literal: true

# == Schema Information
#
# Table name: founder_club_claims
#
#  id                 :integer          not null, primary key
#  deal_id            :integer          not null
#  user_id            :integer          not null
#  redemption_code_id :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_founder_club_claims_on_deal_id_and_user_id  (deal_id,user_id) UNIQUE
#  index_founder_club_claims_on_redemption_code_id   (redemption_code_id)
#  index_founder_club_claims_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (deal_id => founder_club_deals.id)
#  fk_rails_...  (redemption_code_id => founder_club_redemption_codes.id)
#  fk_rails_...  (user_id => users.id)
#

class FounderClub::Claim < ApplicationRecord
  include Namespaceable

  belongs_to :user, inverse_of: :founder_club_claims
  belongs_to :deal, class_name: 'FounderClub::Deal', counter_cache: true, inverse_of: :claims
  belongs_to :redemption_code, class_name: 'FounderClub::RedemptionCode', counter_cache: true, inverse_of: :claims

  attr_readonly :deal_id, :user_id, :redemption_code_id

  validate :ensure_redemption_code_and_deal_match, on: :create

  private

  def ensure_redemption_code_and_deal_match
    errors.add :redemption_code_id, "isn't for given deal" if redemption_code.deal != deal
  end
end
