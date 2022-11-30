# frozen_string_literal: true

# == Schema Information
#
# Table name: product_review_summaries
#
#  id              :bigint(8)        not null, primary key
#  product_id      :bigint(8)        not null
#  start_date      :date             not null
#  end_date        :date             not null
#  reviewers_count :integer          default(0), not null
#  reviews_count   :integer          default(0), not null
#  rating          :decimal(3, 2)    default(0.0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_product_review_summaries_on_product_id  (product_id)
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#
class Products::ReviewSummary < ApplicationRecord
  self.table_name = 'product_review_summaries'

  REVIEW_THRESHOLD = 3

  belongs_to :product

  has_many :review_associations, class_name: 'Products::ReviewSummaryAssociation', foreign_key: :product_review_summary_id, dependent: :destroy
  has_many :reviews, through: :review_associations
  has_many :reviewers, through: :reviews, source: :user, class_name: 'User'
  has_many :positive_tags, through: :reviews, source: :positive_tags, class_name: 'ReviewTag'

  has_many :activity_events, class_name: 'Products::ActivityEvent', as: :subject, dependent: :destroy

  validates :start_date, :end_date, presence: true

  def self.create_for_time_period(product, start_date, end_date)
    start_date = start_date.to_date
    end_date = end_date.to_date

    reviews = product.reviews.where('DATE(created_at) >= ? AND DATE(created_at) <= ?', start_date, end_date)
    return if reviews.count < REVIEW_THRESHOLD

    transaction do
      summary = create!(product: product, start_date: start_date, end_date: end_date)

      reviews.find_each do |review|
        Products::ReviewSummaryAssociation.create!(summary: summary, review: review)
      end

      summary.update!(
        reviews_count: reviews.count,
        reviewers_count: reviews.select(:user_id).distinct.count,
        rating: Posts::ReviewRating.star_rating(summary),
      )

      summary
    end
  end

  def reviewers_for_feed(current_user: nil)
    result = current_user ? reviewers.order_by_friends(current_user) : reviewers
    result.by_follower_count
  end

  def positive_tags_for_feed
    positive_tags.group('review_tags.id').order('COUNT(review_tags.id) DESC')
  end
end
