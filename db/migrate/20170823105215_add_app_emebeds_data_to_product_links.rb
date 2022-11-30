class AddAppEmebedsDataToProductLinks < ActiveRecord::Migration
  def change
    change_table :product_links do |t|
      t.decimal :rating, precision: 3, scale: 2, null: true
      t.decimal :price, precision: 8, scale: 2, null: true
      t.string :devices, array: true, default: [], null: false
    end
  end
end
