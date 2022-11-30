# frozen_string_literal: true

# == Schema Information
#
# Table name: ads_budgets
#
#  id                      :bigint(8)        not null, primary key
#  campaign_id             :bigint(8)        not null
#  kind                    :string           not null
#  channels_count          :integer          default(0), not null
#  active_channels_count   :integer          default(0), not null
#  amount                  :decimal(15, 2)   not null
#  start_time              :datetime
#  end_time                :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  unit_price              :decimal(8, 2)
#  closes_count            :integer          default(0), not null
#  clicks_count            :integer          default(0), not null
#  impressions_count       :integer          default(0), not null
#  active_start_hour       :integer          default(0), not null
#  active_end_hour         :integer          default(23)
#  daily_cap_amount        :decimal(15, 2)   default(0.0), not null
#  today_impressions_count :integer          default(0), not null
#  today_cap_reached       :boolean          default(FALSE), not null
#  today_date              :string
#  name                    :string
#  tagline                 :string
#  thumbnail_uuid          :string
#  cta_text                :string
#  url                     :string
#  url_params              :json
#
# Indexes
#
#  index_ads_budgets_on_campaign_id  (campaign_id)
#  index_ads_budgets_on_end_time     (end_time) WHERE (end_time IS NOT NULL)
#  index_ads_budgets_on_start_time   (start_time) WHERE (start_time IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (campaign_id => ads_campaigns.id)
#

class Ads::Budget < ApplicationRecord
  include Namespaceable
  include Uploadable

  audited only: %i(campaign_id kind amount start_time end_time unit_price active_start_hour active_end_hour daily_cap_amount)

  uploadable :thumbnail

  has_associated_audits

  extension RefreshExplicitCounterCache, :campaign, :active_budgets_count

  belongs_to :campaign,
             class_name: 'Ads::Campaign',
             inverse_of: :budgets,
             counter_cache: true

  has_many :channels,
           class_name: 'Ads::Channel',
           foreign_key: :budget_id,
           inverse_of: :budget,
           dependent: :destroy

  has_many :media, dependent: :destroy, as: :subject

  has_one :newsletter,
          class_name: 'Ads::Newsletter',
          foreign_key: :budget_id,
          inverse_of: :budget,
          dependent: :destroy,
          autosave: true

  has_one :newsletter_sponsor,
          class_name: 'Ads::NewsletterSponsor',
          foreign_key: :budget_id,
          inverse_of: :budget,
          dependent: :destroy,
          autosave: true

  enum kind: {
    timed: 'timed',
    cpm: 'cpm',
  }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :kind, presence: true
  validates :start_time, presence: true, if: -> { end_time.present? }
  validates :end_time, presence: true, if: -> { start_time.present? && timed? }
  validates :unit_price, presence: true, if: -> { cpm? }

  validates :daily_cap_amount, presence: true, numericality: { greater_than_or_equal: 0 }

  validates :active_start_hour, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 23, only_integer: true }
  validates :active_end_hour, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 23, only_integer: true }

  validate :ensure_end_time_after_start_time
  validate :ensure_active_end_hour_after_start_hour
  validate :ensure_daily_cap_amount_not_bigger_than_amount

  validate :ensure_no_timed_ads, on: :create

  scope :active, -> { where('active_channels_count > 0').where(arel_table[:start_time].lteq(Time.current)) }

  scope :with_impressions, lambda {
    impressions = arel_table[:amount] * 1000 / arel_table[:unit_price]
    with_impressions = (impressions - arel_table[:impressions_count]).gt(0)

    cpm.where.not(amount: nil, unit_price: nil).where(with_impressions)
  }

  def fill
    return 0 unless cpm?

    fill_dollar * 100 / amount
  end

  def fill_dollar
    return 0 unless cpm?

    (impressions_count * unit_price) / 1000
  end

  def impressions
    return 0 unless cpm? && amount.present? && unit_price&.nonzero?

    (amount * 1000 / unit_price).floor
  end

  def available_impressions
    [impressions - impressions_count, 0].max.floor
  end

  def active?(now: Time.current)
    return false if active_channels_count.zero?
    return false if start_time.blank?
    return true if cpm?

    start_time <= now && (end_time.blank? || end_time > now)
  end

  def pending?
    return false if active_channels_count.zero?
    return false if start_time.blank?

    start_time > Time.current
  end

  def complete?
    return true if timed? && end_time.try(:past?)

    fill >= 100
  end

  def number_of_days
    return unless start_time.present? && end_time.present?

    (end_time.to_date - start_time.to_date).to_i
  end

  # NOTE(DZ): Do not use ExplicitCounterCache since we need callbacks to
  # cascade `active` counter cache up to campaign level
  def refresh_active_channels_count
    new_count = channels.active.size

    return if active_channels_count == new_count
    return if destroyed?

    update_columns active_channels_count: new_count, updated_at: Time.current

    campaign.refresh_active_budgets_count
  end

  def daily_cap?
    daily_cap_amount > 0
  end

  private

  def ensure_end_time_after_start_time
    return if end_time.blank? || start_time.blank?
    return if end_time > start_time

    errors.add :end_time, 'cannot be before start_time'
  end

  def ensure_active_end_hour_after_start_hour
    return if active_end_hour.blank? || active_start_hour.blank?
    return if active_end_hour > active_start_hour

    errors.add :active_end_hour, "cannot be smaller than active start hour (#{ active_start_hour })"
  end

  def ensure_daily_cap_amount_not_bigger_than_amount
    return if daily_cap_amount.nil? || amount.nil?
    return if daily_cap_amount <= amount

    errors.add :daily_cap_amount, "cannot bigger than amount (#{ amount })"
  end

  def ensure_no_timed_ads
    errors.add :kind, 'timed ads are disabled' if timed?
  end
end
