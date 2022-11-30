class CreateGoldenKittyFinalists < ActiveRecord::Migration[5.0]
  def change
    create_table :golden_kitty_finalists do |t|
      t.references :post, foreign_key: true, null: false
      t.references :golden_kitty_category, foreign_key: true, null: false
      t.boolean :winner, null: false, default: false
      t.integer :votes_count, null: false, default: 0
      t.integer :credible_votes_count, null: false, default: 0

      t.timestamps
    end

    add_index :golden_kitty_finalists, %i(post_id golden_kitty_category_id), unique: true, name: 'index_golden_kitty_finalists_post_category'
  end
end
