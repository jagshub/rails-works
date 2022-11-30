class CreateProductReviewSummaries < ActiveRecord::Migration[6.1]
  def change
    create_table :product_review_summaries do |t|
      t.references :product, null: false, foreign_key: true, index: true
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :reviewers_count, null: false, default: 0
      t.integer :reviews_count, null: false, default: 0
      t.decimal :rating, precision: 3, scale: 2, null: false, default: 0

      t.timestamps null: false
    end

    create_table :product_review_summary_associations do |t|
      t.references :product_review_summary, null: false, foreign_key: true, index: false
      t.references :review,                 null: false, foreign_key: true, index: false

      t.index [:product_review_summary_id, :review_id], name: 'index_product_review_summaries_to_reviews'
      t.index [:review_id, :product_review_summary_id], name: 'index_reviews_to_product_review_summaries'
    end
  end
end
