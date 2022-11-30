# frozen_string_literal: true

# == Schema Information
#
# Table name: product_requests
#
#  id                             :integer          not null, primary key
#  user_id                        :integer          not null
#  title                          :text             not null
#  body                           :text
#  recommended_products_count     :integer          default(0), not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  followers_count                :integer          default(0), not null
#  edited_at                      :datetime
#  hidden_at                      :datetime
#  comments_count                 :integer          default(0), not null
#  duplicate_of_id                :integer
#  seo_title                      :text
#  seo_description                :text
#  featured_at                    :datetime
#  related_product_requests_count :integer          default(0), not null
#  anonymous                      :boolean          default(FALSE)
#  kind                           :integer          not null
#  user_flags_count               :integer          default(0)
#
# Indexes
#
#  index_product_requests_on_comments_count   (comments_count)
#  index_product_requests_on_duplicate_of_id  (duplicate_of_id)
#  index_product_requests_on_featured_at      (featured_at)
#  index_product_requests_on_followers_count  (followers_count)
#  index_product_requests_on_hidden_at        (hidden_at)
#  index_product_requests_on_kind             (kind)
#  index_product_requests_on_user_id          (user_id)
#

class ProductRequest < ApplicationRecord
  include ExplicitCounterCache
  include Featurable
  include Commentable
  include UserFlaggable

  belongs_to :duplicate_of, class_name: 'ProductRequest', optional: true
  belongs_to :user, counter_cache: true
  has_many :flags, as: :subject, dependent: :destroy
  has_many :recommended_products, dependent: :destroy
  has_many :recommendations, through: :recommended_products

  has_many :user_follow_product_request_associations, dependent: :delete_all
  has_many :followers, through: :user_follow_product_request_associations, source: :user, counter_cache: false

  has_many :product_request_topic_associations, dependent: :delete_all, inverse_of: :product_request
  has_many :topics, through: :product_request_topic_associations, source: :topic

  has_many :product_request_related_product_request_associations, dependent: :delete_all
  has_many :product_request_related_reverse_product_request_associations, class_name: 'ProductRequestRelatedProductRequestAssociation', foreign_key: :related_product_request_id, dependent: :delete_all
  has_many :related_product_requests, through: :product_request_related_product_request_associations, source: :related_product_request

  validates :kind, presence: true
  validates :title, presence: true, length: { maximum: 100 }

  enum kind: { product_request: 0, advice: 1 }

  explicit_counter_cache :followers_count, -> { user_follow_product_request_associations }
  explicit_counter_cache :recommended_products_count, -> { recommended_products }
  explicit_counter_cache :related_product_requests_count, -> { product_request_related_product_request_associations }

  scope :by_date, -> { order(arel_table[:created_at].desc) }
  scope :by_recommended_products_count, -> { order(arel_table[:recommended_products_count].desc) }
  scope :featured, -> { where(arel_table[:featured_at].lt(DateTime.current)).order(arel_table[:featured_at].desc) }
  scope :needs_help, -> { where(arel_table[:recommended_products_count].lt(5)) }
  scope :not_anonymous, -> { where(anonymous: false) }
  scope :not_duplicate, -> { where(duplicate_of_id: nil) }
  scope :sitemap, -> { not_duplicate.visible.where(arel_table[:featured_at].not_eq(nil).or(arel_table[:recommended_products_count].gt(2))) }
  scope :visible, -> { where(hidden_at: nil) }

  def duplicate?
    duplicate_of.present?
  end

  def hidden?
    hidden_at?
  end

  def hide!
    update!(hidden_at: DateTime.current)
  end

  def unhide!
    update!(hidden_at: nil)
  end

  def to_param
    "#{ id }-#{ title.parameterize }"
  end
end
