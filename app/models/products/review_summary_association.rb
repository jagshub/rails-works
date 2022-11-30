# frozen_string_literal: true

# == Schema Information
#
# Table name: product_review_summary_associations
#
#  id                        :bigint(8)        not null, primary key
#  product_review_summary_id :bigint(8)        not null
#  review_id                 :bigint(8)        not null
#
# Indexes
#
#  index_product_review_summaries_to_reviews  (product_review_summary_id,review_id)
#  index_reviews_to_product_review_summaries  (review_id,product_review_summary_id)
#
# Foreign Keys
#
#  fk_rails_...  (product_review_summary_id => product_review_summaries.id)
#  fk_rails_...  (review_id => reviews.id)
#
class Products::ReviewSummaryAssociation < ApplicationRecord
  self.table_name = 'product_review_summary_associations'

  belongs_to :summary, class_name: 'Products::ReviewSummary', foreign_key: :product_review_summary_id
  belongs_to :review, inverse_of: :review_summary_associations
end
