class CreateRecommendedProducts < ActiveRecord::Migration
  def change
    create_table :recommended_products do |t|
      t.references :request, index: true, foreign_key: false, null: false
      t.references :product, index: true, foreign_key: false
      t.text :external_title
      t.text :external_image_url
      t.text :external_url
      t.integer :votes_count, null: false, default: 0

      t.timestamps null: false
    end
  end
end
