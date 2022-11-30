# frozen_string_literal: true

# == Schema Information
#
# Table name: ads_channels
#
#  id                :bigint(8)        not null, primary key
#  budget_id         :bigint(8)        not null
#  kind              :string           not null
#  bundle            :string           not null
#  active            :boolean          default(TRUE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  closes_count      :integer          default(0), not null
#  clicks_count      :integer          default(0), not null
#  impressions_count :integer          default(0), not null
#  weight            :integer          default(0), not null
#  url               :string           not null
#  url_params        :json             not null
#  application       :string           default("all_apps"), not null
#  name              :string
#  tagline           :string
#  thumbnail_uuid    :string
#
# Indexes
#
#  index_ads_channels_find_ad                           (weight DESC,active,kind)
#  index_ads_channels_on_active                         (active)
#  index_ads_channels_on_budget_id_and_kind_and_bundle  (budget_id,kind,bundle) UNIQUE
#  index_ads_channels_on_bundle                         (bundle)
#  index_ads_channels_on_kind                           (kind)
#
# Foreign Keys
#
#  fk_rails_...  (budget_id => ads_budgets.id)
#

class Ads::Channel < ApplicationRecord
  include HasUrlParams
  include Namespaceable
  include Uploadable

  uploadable :thumbnail
  extension RefreshExplicitCounterCache, :budget, :active_channels_count

  audited associated_with: :budget, only: %i(
    active
    kind
    bundle
    weight
    url
    url_params
  )

  belongs_to :budget,
             class_name: 'Ads::Budget',
             inverse_of: :channels,
             counter_cache: true

  has_many :interactions,
           class_name: 'Ads::Interaction',
           inverse_of: :channel,
           foreign_key: :channel_id,
           dependent: :destroy

  has_many :media, dependent: :destroy, as: :subject

  enum bundle: Ads::TopicBundle.enum, _prefix: true

  enum kind: {
    feed: 'feed',
    sidebar: 'sidebar',
    bundle_priority: 'bundle_priority',
  }

  enum application: {
    web: 'web',
    ios: 'ios',
    android: 'android',
    all_apps: 'all_apps',
  }

  validates :kind, presence: true
  validates :bundle, presence: true
  validates :url, presence: true, format: URI.regexp(%w(http https))
  validate :ensure_channel_uniqueness
  validate :ensure_bundle_and_kind_are_valid
  validate :ensure_not_using_deprecated_bundles, on: :create

  # NOTE(DZ): This is used for active_admin filtering
  ransacker(
    :bundle,
    formatter: ->(value) { [value, 'everything'] },
  ) do |parent|
    parent.table[:bundle]
  end

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :with_bundles, ->(bundles = []) { where(bundle: Array(bundles)) }
  scope :with_application, ->(app) { where(application: [app.to_s, 'all_apps'].uniq) }
  # NOTE(DZ): This is used by admin page for ransacker
  scope :with_bundles_eq, ->(bundles = []) { with_bundles(bundles) }
  scope :by_weight, -> { order(weight: :desc) }

  # NOTE(DZ): Composite sort order. For most cases, use this
  scope :by_priority, lambda {
    left_joins(:budget)
      .by_weight
      .order(Arel.sql('RANDOM()'))
  }

  def url=(value)
    self[:url] = value.strip
  end

  class << self
    def ransackable_scopes(_auth_object = nil)
      [:with_bundles_eq]
    end
  end

  private

  def ensure_channel_uniqueness
    another = self.class.where(kind: kind, bundle: bundle, budget: budget)
    return unless another.where.not(id: id).exists?

    errors.add(:base, 'cannot have duplicate channels')
  end

  def ensure_bundle_and_kind_are_valid
    return unless sidebar? && bundle_homepage_primary?

    errors.add :bundle, 'cannot be homepage when kind is sidebar'
  end

  def ensure_not_using_deprecated_bundles
    return unless Ads::TopicBundle::DELETED_BUNDLES.include?(bundle)

    errors.add :bundle, "'#{ bundle }' is deprecated and shouldn't be used"
  end
end
