class CreateGoldenKittyNominees < ActiveRecord::Migration[5.0]
  def change
    create_table :golden_kitty_nominees do |t|
      t.references :golden_kitty_category, foreign_key: true, null: false
      t.references :post, null: false
      t.references :user, null: false
      t.string :comment

      t.timestamps
    end

    add_index :golden_kitty_nominees, %i(post_id golden_kitty_category_id user_id), unique: true, name: 'index_gk_post_id_category_id_user_id_u'
  end
end
