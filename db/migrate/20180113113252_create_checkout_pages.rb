class CreateCheckoutPages < ActiveRecord::Migration[5.0]
  def change
    create_table :checkout_pages do |t|
      t.string :name, null: false
      t.string :sku, null: false
      t.string :slug, null: false
      t.text :body, null: false
      t.datetime :trashed_at, null: true
      t.timestamps null: false
    end

    add_index :checkout_pages, :slug, unique: true
  end
end
