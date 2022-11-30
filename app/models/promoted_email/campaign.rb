# frozen_string_literal: true

# == Schema Information
#
# Table name: promoted_email_campaigns
#
#  id                        :bigint(8)        not null, primary key
#  title                     :string           not null
#  tagline                   :string           not null
#  thumbnail_uuid            :string           not null
#  promoted_type             :integer          default("homepage"), not null
#  start_date                :datetime         not null
#  end_date                  :datetime         not null
#  webhook_enabled           :boolean          default(FALSE), not null
#  webhook_url               :string
#  webhook_auth_header       :string
#  webhook_payload           :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  campaign_name             :string
#  promoted_email_ab_test_id :bigint(8)
#  signups_count             :integer          default(0), not null
#  cta_text                  :string
#
# Indexes
#
#  index_promoted_email_campaigns_on_ab_test_id     (promoted_email_ab_test_id) WHERE (promoted_email_ab_test_id IS NOT NULL)
#  index_promoted_email_campaigns_on_campaign_name  (campaign_name) WHERE (campaign_name IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (promoted_email_ab_test_id => promoted_email_ab_tests.id)
#

class PromotedEmail::Campaign < ApplicationRecord
  # NOTE(DZ): PromotedEmail is deprecated
  def readonly?
    true
  end

  include Namespaceable
  include Uploadable
  include RandomOrder
  include ExplicitCounterCache

  attr_accessor :ab_variant

  before_validation :clean_webhook_payload

  validates :title, presence: true
  validates :tagline, presence: true
  validates :thumbnail_uuid, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :webhook_url, presence: true, if: :webhook_enabled?
  validate :end_date_value, if: :dates_present?
  validate :url, if: :webhook_url?
  validate :ensure_not_deprecated

  uploadable :thumbnail

  # NOTE(DZ): signup_onboarding is deprecated
  enum promoted_type: { signup_onboarding: 0, homepage: 1, postpage_sidebar: 2 }

  has_many :signups, class_name: '::PromotedEmail::Signup', foreign_key: 'promoted_email_campaign_id', inverse_of: :promoted_email_campaign, dependent: :destroy

  belongs_to :promoted_email_ab_test, class_name: '::PromotedEmail::AbTest', inverse_of: :campaigns, optional: true
  belongs_to :campaign_config, class_name: '::PromotedEmail::CampaignConfig', inverse_of: :campaigns, optional: true, primary_key: 'campaign_name', foreign_key: 'campaign_name'

  explicit_counter_cache :signups_count, -> { signups }

  accepts_nested_attributes_for :campaign_config

  scope :by_active, -> { left_outer_joins(:campaign_config).where('promoted_email_campaign_configs IS NULL OR promoted_email_campaign_configs.signups_count < promoted_email_campaign_configs.signups_cap OR promoted_email_campaign_configs.signups_cap = -1') }

  class << self
    # NOTE(DZ): Overwrite default types to match usage in active admin. Numeric
    # enums do not behave nicely with formtastic select `collection:` key
    def promoted_types
      {
        homepage: :homepage,
        postpage_sidebar: :postpage_sidebar,
      }
    end
  end

  def all_campaigns
    return [] unless campaign_name?

    ::PromotedEmail::Campaign.where(campaign_name: campaign_name)
  end

  private

  def end_date_value
    return if end_date > start_date

    errors.add :end_date, 'value should be greater than start_date'
  end

  def dates_present?
    start_date.present? && end_date.present?
  end

  def url
    errors.add :webhook_url, 'is not valid' unless LinkSpect.valid?(url: webhook_url)
  end

  def clean_webhook_payload
    return if webhook_payload.blank?

    self.webhook_payload = webhook_payload.delete(' ').delete_suffix(',')
  end

  def ensure_not_deprecated
    return unless signup_onboarding?

    errors.add :promoted_type, 'signup_onboarding is deprecated'
  end
end
