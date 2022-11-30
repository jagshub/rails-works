# frozen_string_literal: true

# == Schema Information
#
# Table name: recommended_products
#
#  id                   :integer          not null, primary key
#  product_request_id   :integer          not null
#  name                 :text
#  votes_count          :integer          default(0), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  credible_votes_count :integer          default(0), not null
#  score_multiplier     :float            default(1.0)
#  new_product_id       :bigint(8)        not null
#
# Indexes
#
#  index_recommended_products_on_credible_votes_count  (credible_votes_count)
#  index_recommended_products_on_new_product_id        (new_product_id)
#

class RecommendedProduct < ApplicationRecord
  include Votable

  self.ignored_columns = %i(product_id)

  belongs_to :product_request, touch: true
  belongs_to :product, class_name: 'Product', foreign_key: :new_product_id

  has_many :recommendations, dependent: :destroy
  has_many :posts, through: :product

  validates :new_product_id, uniqueness: { scope: :product_request_id }

  after_commit :refresh_counters, only: %i(create destroy)

  scope :by_credible_votes_count_ranking, -> { order(Arel.sql('recommended_products.credible_votes_count * recommended_products.score_multiplier DESC')) }
  scope :by_date, -> { order(arel_table[:created_at].asc) }
  scope :featured, -> { joins(:product).merge(Product.joins(:posts).merge(Post.featured)).group('recommended_products.id') }

  delegate :tagline, to: :post_fallback, allow_nil: true

  def name_with_fallback
    name.presence || post_fallback&.name
  end

  private

  def refresh_counters
    product_request.refresh_recommended_products_count if product_request.present?
  end

  def post_fallback
    return @post_fallback if instance_variable_defined? '@post_fallback'

    @post_fallback = product.posts.first
  end
end
