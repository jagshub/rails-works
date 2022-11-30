# frozen_string_literal: true

# == Schema Information
#
# Table name: legacy_product_links
#
#  id           :integer          not null, primary key
#  url          :text             not null
#  short_code   :text             not null
#  store        :integer
#  created_at   :datetime
#  updated_at   :datetime
#  user_id      :integer          not null
#  primary_link :boolean          default(FALSE), not null
#  clean_url    :text
#  product_id   :integer
#  rating       :decimal(3, 2)
#  price        :decimal(8, 2)
#  devices      :string           default([]), not null, is an Array
#  broken       :boolean          default(FALSE), not null
#  post_id      :integer
#
# Indexes
#
#  index_legacy_product_links_on_post_id                      (post_id)
#  index_legacy_product_links_on_primary_link_and_post_id     (primary_link,post_id)
#  index_legacy_product_links_on_product_id_and_primary_link  (product_id,primary_link)
#  index_legacy_product_links_on_short_code                   (short_code) UNIQUE
#  index_legacy_product_links_on_store_and_post_id            (store,post_id) WHERE (post_id IS NOT NULL)
#  index_legacy_product_links_on_user_id                      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#  fk_rails_...  (product_id => legacy_products.id)
#

class LegacyProductLink < ApplicationRecord
  HasUniqueCode.define self, field_name: :short_code, length: 14

  belongs_to :post, inverse_of: :links, touch: true, foreign_key: :post_id
  belongs_to :user

  has_many :house_keeper_broken_links, foreign_key: :product_link_id, inverse_of: :product_link, dependent: :destroy

  validates :short_code, presence: true, uniqueness: true
  validates :primary_link, uniqueness: { scope: :post }, if: proc { |l| l.post_id? && l.primary_link? }

  # NOTE(LukasFittl): validates_url parsing is inherently broken since it only
  #   validates that something is an URI, not an URL.
  validates :url, presence: true, url: true, format: { with: /\./ }
  validate :clean_url_is_set

  enum store: PlatformStores.enums

  before_validation :set_store_and_clean_url
  before_destroy :reject_if_primary_link
  after_update :reset_broken_if_updated

  scope :primary, -> { where(primary_link: true) }
  scope :not_primary, -> { where(primary_link: false) }
  scope :by_date, -> { order(created_at: :asc) }
  scope :not_broken, -> { where(broken: false) }
  scope :broken, -> { where(broken: true) }

  # Auto-add http:// to urls if not provided
  def url=(new_url)
    if new_url.present?
      new_url = new_url.strip
      new_url = 'http://' + new_url unless new_url =~ /^https?/i
    end

    super(new_url)
  end

  def store_name
    PlatformStores.find_name_for_store(store)
  end

  def os
    PlatformStores.find_os_for_store(store)
  end

  private

  def reject_if_primary_link
    return unless primary_link?

    errors.add(:base, "can't delete the primary link of a product")
    throw :abort
  end

  def set_store_and_clean_url
    self.clean_url = UrlParser.clean_url(url)
    self.store = PlatformStores.store_key_by_url(url)
  end

  def reset_broken_if_updated
    return unless broken? && saved_change_to_url?

    HouseKeeper::Reset.product_link(self)
  end

  def clean_url_is_set
    return true if clean_url.present?

    errors.add(:url, 'invalid')
  end
end
