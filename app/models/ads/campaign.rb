# frozen_string_literal: true

# == Schema Information
#
# Table name: ads_campaigns
#
#  id                   :bigint(8)        not null, primary key
#  post_id              :bigint(8)
#  name                 :string           not null
#  tagline              :string           not null
#  thumbnail_uuid       :string           not null
#  url                  :string           not null
#  url_params           :json             not null
#  budgets_count        :integer          default(0), not null
#  active_budgets_count :integer          default(0), not null
#  cta_text             :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_ads_campaigns_on_post_id  (post_id)
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#

class Ads::Campaign < ApplicationRecord
  include ExplicitCounterCache
  include HasUrlParams
  include Namespaceable
  include Uploadable

  explicit_counter_cache :active_budgets_count, -> { budgets.active }

  uploadable :thumbnail

  audited only: %i(post_id name tagline thumbnail_uuid url url_params cta_text)

  belongs_to :post, inverse_of: :ad_campaigns, optional: true

  has_many :budgets,
           class_name: 'Ads::Budget',
           inverse_of: :campaign,
           foreign_key: :campaign_id,
           dependent: :destroy

  has_many :media, dependent: :destroy, as: :subject

  validates :name, presence: true
  validates :tagline, presence: true
  validates :thumbnail, presence: true
  validates :url, presence: true, format: URI.regexp(%w(http https))
end
