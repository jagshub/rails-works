# frozen_string_literal: true

# == Schema Information
#
# Table name: founder_club_deals
#
#  id                    :integer          not null, primary key
#  title                 :string           not null
#  logo_uuid             :string
#  value                 :string           not null
#  summary               :string           not null
#  redemption_url        :string           not null
#  details               :text             not null
#  terms                 :text             not null
#  how_to_claim          :text             not null
#  active                :boolean          default(TRUE), not null
#  trashed_at            :datetime
#  priority              :integer          default(0), not null
#  badges                :string           default([]), not null, is an Array
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  redemption_method     :integer          default(NULL)
#  claims_count          :integer          default(0)
#  logo_with_colors_uuid :string
#  company_name          :string
#  product_id            :bigint(8)
#
# Indexes
#
#  index_founder_club_deals_on_active_and_trashed_at  (active,trashed_at) WHERE ((active = true) AND (trashed_at IS NULL))
#  index_founder_club_deals_on_badges                 (badges) USING gin
#  index_founder_club_deals_on_product_id             (product_id)
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id) ON DELETE => nullify
#

class FounderClub::Deal < ApplicationRecord
  BADGES = ['used_by_producthunt', 'launch_partner', 'popular', 'new'].freeze

  include Namespaceable
  include Trashable
  include Prioritisable
  include Uploadable

  include PgSearch::Model
  pg_search_scope :search_by_title_or_company_name,
                  against: {
                    company_name: 'A',
                    title: 'B',
                  },
                  using: {
                    tsearch: { prefix: true },
                  }

  uploadable :logo
  uploadable :logo_with_colors

  has_many :claims, class_name: 'FounderClub::Claim', dependent: :destroy, inverse_of: :deal
  has_many :redemption_codes, class_name: 'FounderClub::RedemptionCode', dependent: :destroy, inverse_of: :deal
  has_many :access_requests, class_name: 'FounderClub::AccessRequest', dependent: :nullify, inverse_of: :deal

  belongs_to :product, optional: true, inverse_of: :founder_club_deals

  enum redemption_method: { limited: 1, unlimited: 2 }

  scope :active, -> { not_trashed.where(active: true) }
  scope :inactive, -> { not_trashed.where(active: false) }

  scope :ordered_by_user_claim, lambda { |user|
    return if user.blank?

    joins("LEFT OUTER JOIN founder_club_claims ON founder_club_claims.deal_id = founder_club_deals.id AND founder_club_claims.user_id = #{ user.id }")
      .order('founder_club_claims.id NULLS FIRST')
  }

  scope :by_popularity, -> { select("founder_club_deals.*, (CASE 'popular' = ANY(founder_club_deals.badges) WHEN true THEN 1 ELSE 0 END) as popular").order('popular DESC') }

  validates :title, presence: true, length: { maximum: 60 }
  validates :summary, length: { maximum: 250, allow_blank: true }
  validates :redemption_url, url: { allow_blank: true }

  class << self
    def graphql_type
      Graph::Types::FounderClubDealType
    end
  end
end
