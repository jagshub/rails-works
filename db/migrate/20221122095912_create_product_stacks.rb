class CreateProductStacks < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!
  
  def change
    create_table :product_stacks do |t|
      t.belongs_to :product, null: false, index: false, foreign: true
      t.belongs_to :user, null: false, index: true, foreign: true
      t.string :source, null: false

      t.timestamps
    end

    add_index :product_stacks,
               %i(product_id user_id),
               unique: true,
               algorithm: :concurrently

    add_column :products, :stacks_count, :integer, default: 0
  end
end
