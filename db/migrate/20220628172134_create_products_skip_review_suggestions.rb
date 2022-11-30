class CreateProductsSkipReviewSuggestions < ActiveRecord::Migration[6.1]
  def change
    create_table :products_skip_review_suggestions do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end

    add_index :products_skip_review_suggestions,
              %i(user_id product_id),
              unique: true,
              name: 'index_skip_review_suggestions_on_user_and_product'
  end
end
