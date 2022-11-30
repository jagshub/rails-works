class CreateTableEmbeds < ActiveRecord::Migration
  def change
    create_table :embeds do |t|
      t.string :clean_url, null: true
      t.integer :provider, null: false
      t.references :product, null: false

      t.string :title, null: true
      t.string :description, null: true
      t.string :author, null: true

      t.decimal :rating, precision: 3, scale: 2, null: true
      t.decimal :price, precision: 8, scale: 2, null: true

      t.timestamps null: false
    end

    add_index :embeds, %i(clean_url product_id), unique: true
  end
end
