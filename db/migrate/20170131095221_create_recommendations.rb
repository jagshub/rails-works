class CreateRecommendations < ActiveRecord::Migration
  def change
    create_table :recommendations do |t|
      t.references :recommended_product, index: true, foreign_key: false, null: false
      t.references :user, index: true, foreign_key: false, null: false
      t.text :body, null: false
      t.text :disclosure
      t.integer :votes_count, null: false, default: 0

      t.timestamps null: false
    end
  end
end
