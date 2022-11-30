class CreateProductAlternativeSuggestions < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    create_table :product_alternative_suggestions do |t|
      t.belongs_to :product, null: false, index: false, foreign: { to_table: 'products' }
      t.belongs_to :alternative_product, null: false, index: true, foreign: { to_table: 'products' }
      t.belongs_to :user, optional: true 
      t.string :source, null: false

      t.timestamps
    end

    add_index :product_alternative_suggestions,
               %i(product_id alternative_product_id),
               unique: true,
               algorithm: :concurrently,
               name: 'index_alternative_suggestions_on_from_product_id_and_to_product'
  end
end
