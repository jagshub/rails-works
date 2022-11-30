# frozen_string_literal: true

# == Schema Information
#
# Table name: promoted_product_campaigns
#
#  id                :bigint(8)        not null, primary key
#  name              :string           not null
#  impressions_cap   :integer          default(-1), not null
#  impressions_count :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class PromotedProductCampaign < ApplicationRecord
  # NOTE(DZ): PromotedProductCampaign is deprecated. Use `Ads::Campaign` instead
  # Deprecation date 2020-01-04
  def readonly?
    true
  end

  has_many :promoted_products, inverse_of: :campaign, dependent: :nullify

  validates :name, presence: true
end
