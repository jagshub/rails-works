class CreateNewProductLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :product_links do |t|
      t.string :url,           null: false, index: true
      t.string :source,        null: false
      t.string :url_kind,      null: false
      t.integer :clicks_count, null: false, default: 0

      t.references :product, null: true, index: true

      t.timestamps null: false
    end
  end
end
