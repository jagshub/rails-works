class CreatePromotedProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :promoted_products do |t|
      t.datetime :promoted_at
      t.references :post, null: false, foreign_key: true

      t.timestamps
    end
  end
end
