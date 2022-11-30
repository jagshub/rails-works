class CreateProductPostAssociations < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    create_table :product_post_associations do |t|
      t.references :product, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true, index: { unique: true }
      t.string :kind, null: false

      t.timestamps
    end
  end
end
