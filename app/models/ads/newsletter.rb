# frozen_string_literal: true

# == Schema Information
#
# Table name: ads_newsletters
#
#  id             :bigint(8)        not null, primary key
#  budget_id      :bigint(8)        not null
#  newsletter_id  :bigint(8)
#  name           :string           not null
#  tagline        :string           not null
#  thumbnail_uuid :string           not null
#  url            :string           not null
#  url_params     :json             not null
#  opens_count    :integer          default(0), not null
#  clicks_count   :integer          default(0), not null
#  sents_count    :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  weight         :integer          default(0), not null
#  active         :boolean          default(TRUE)
#
# Indexes
#
#  index_ads_newsletters_on_active_and_weight  (active,weight)
#  index_ads_newsletters_on_budget_id          (budget_id)
#  index_ads_newsletters_on_newsletter_id      (newsletter_id)
#
# Foreign Keys
#
#  fk_rails_...  (budget_id => ads_budgets.id)
#

# TODO(DZ): Deprecate & Remove `newsletter_id` colum`
class Ads::Newsletter < ApplicationRecord
  include HasUrlParams
  include Namespaceable
  include Uploadable

  audited associated_with: :budget, only: %i(
    active
    newsletter_id
    name
    tagline
    thumbnail_uuid
    url
    url_params
    weight
  )

  belongs_to :budget, class_name: 'Ads::Budget', inverse_of: :newsletter
  belongs_to :newsletter,
             class_name: '::Newsletter',
             inverse_of: :ad,
             optional: true

  has_many :interactions,
           class_name: 'Ads::NewsletterInteraction',
           as: :subject,
           dependent: :destroy

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_weight, -> { order(weight: :desc) }

  BUDGET_COUNTERS = {
    'open' => 'impressions_count',
    'click' => 'clicks_count',
    # NOTE(DZ): We don't record `sent` events for now
    'sent' => nil,
  }.freeze

  uploadable :thumbnail

  validates :name, presence: true
  validates :tagline, presence: true
  validates :thumbnail_uuid, presence: true
  validates :url, presence: true, format: URI.regexp(%w(http https))
  validates :newsletter_id, uniqueness: true, if: -> { newsletter_id.present? }

  # NOTE(DZ): Activate active admin create form
  attribute :_create

  def url=(value)
    self[:url] = value.strip
  end

  def can_be_destroyed?
    persisted? && interactions.empty? &&
      (newsletter_id.blank? || !newsletter.sent?)
  end
end
