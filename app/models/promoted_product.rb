# frozen_string_literal: true

# == Schema Information
#
# Table name: promoted_products
#
#  id                           :integer          not null, primary key
#  promoted_at                  :datetime
#  post_id                      :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  link_visits                  :integer          default(0), not null
#  link_unique_visits           :integer          default(0), not null
#  close_count                  :integer          default(0), not null
#  home_utms                    :text
#  newsletter_utms              :text
#  newsletter_id                :integer
#  newsletter_title             :string
#  newsletter_description       :text
#  newsletter_link              :text
#  newsletter_image_uuid        :string
#  deal                         :string
#  open_as_post_page            :boolean          default(FALSE)
#  promoted_type                :integer          default("standard"), not null
#  start_date                   :datetime
#  end_date                     :datetime
#  topic_bundle                 :string
#  analytics_test               :boolean          default(FALSE)
#  trashed_at                   :datetime
#  url                          :string
#  name                         :string
#  tagline                      :string
#  thumbnail_uuid               :string
#  promoted_product_campaign_id :bigint(8)
#  cta_text                     :string
#  impressions_count            :integer          default(0)
#
# Indexes
#
#  index_promoted_products_on_newsletter_id                   (newsletter_id) UNIQUE
#  index_promoted_products_on_post_id                         (post_id)
#  index_promoted_products_on_promoted_product_campaign_id    (promoted_product_campaign_id)
#  index_promoted_products_on_promoted_type_and_topic_bundle  (promoted_type,topic_bundle) WHERE (topic_bundle IS NOT NULL)
#  index_promoted_products_on_trashed_at                      (trashed_at) WHERE (trashed_at IS NULL)
#
# Foreign Keys
#
#  fk_rails_...  (newsletter_id => newsletters.id)
#  fk_rails_...  (post_id => posts.id)
#  fk_rails_...  (promoted_product_campaign_id => promoted_product_campaigns.id) ON DELETE => nullify
#

class PromotedProduct < ApplicationRecord
  # NOTE(DZ): PromotedProduct is deprecated. Use `Ads::Budget` instead
  # Deprecation date 2020-01-04
  def readonly?
    true
  end

  include Trashable
  include Uploadable
  include RandomOrder

  belongs_to :post, inverse_of: :promotions, optional: true
  belongs_to :newsletter, inverse_of: :promoted_product, optional: true
  belongs_to :campaign, class_name: 'PromotedProductCampaign', foreign_key: 'promoted_product_campaign_id', inverse_of: :promoted_products, optional: true

  has_many :analytics, class_name: 'PromotedAnalytic', inverse_of: :promoted_product, dependent: :destroy

  uploadable :thumbnail

  before_validation :clean_newsletter_link

  with_options if: :standard? do
    validates :promoted_at, presence: true
  end

  with_options if: :related_post? do
    validates :start_date, presence: true
    validates :end_date, presence: true
    validate :end_date_value, if: :dates_present?
  end

  with_options if: :static? do
    validates :name, presence: true
    validates :tagline, presence: true
    validates :thumbnail_uuid, presence: true
  end

  validate :newsletter_availability

  scope :not_closed_by, lambda { |user, track_code|
    # NOTE(DZ): noop if both are missing to prevent loading too much data
    return all if user.blank? && track_code.blank?

    where.not(id: PromotedAnalytic.closes_by(user, track_code).pluck(:promoted_product_id))
  }

  enum promoted_type: {
    standard: 0,
    related_post: 1,
  }

  scope :by_static, -> { where(post_id: nil) }

  scope :by_not_static, -> { where.not(post_id: nil) }

  scope :by_topic_bundles, ->(topic_bundles) { where(topic_bundle: topic_bundles) }

  scope :active_related_post, ->(topic_bundles, date_1, date_2, table = PromotedProduct.arel_table) { by_not_static.related_post.by_topic_bundles(topic_bundles).where(table[:start_date].lteq(date_1).and(table[:end_date].gt(date_2))) }

  scope :active_static_related_post, lambda { |date_1, date_2, table = PromotedProduct.arel_table|
    by_static.related_post
             .joins('LEFT JOIN promoted_product_campaigns AS campaigns ON campaigns.id = promoted_products.promoted_product_campaign_id')
             .where(table[:start_date].lteq(date_1).and(table[:end_date].gt(date_2)))
             .where('campaigns.id IS NULL OR campaigns.impressions_cap = -1 OR campaigns.impressions_count < campaigns.impressions_cap')
  }

  def build_short_url(ref)
    "#{ Rails.application.routes.url_helpers.short_link_to_post_url(post_id) }?ref=#{ ref }&promo_id=#{ id }"
  end

  def newsletter_image
    newsletter_image_uuid.presence || post.thumbnail_image_uuid
  end

  def newsletters_title
    newsletter_title.presence || post.name
  end

  def static?
    post_id.blank?
  end

  private

  def related_post?
    promoted_type == 'related_post'
  end

  def newsletter_availability
    return if newsletter_id.blank?

    promoted = PromotedProduct.find_by(newsletter_id: newsletter_id)
    errors.add(:newsletter_id, "is already used for another PromotedProduct #{ promoted.id }") if promoted.present? && promoted.id != id
  end

  def clean_newsletter_link
    newsletter_link&.strip!
  end

  def end_date_value
    return if end_date > start_date

    errors.add :end_date, 'value should be greater than start_date'
  end

  def dates_present?
    start_date.present? && end_date.present?
  end
end
