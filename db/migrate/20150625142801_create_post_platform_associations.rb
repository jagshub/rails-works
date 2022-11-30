class CreatePostPlatformAssociations < ActiveRecord::Migration
  def change
    create_table :product_platform_associations do |t|
      t.integer :product_id, null: false
      t.integer :platform_id, null: false
      t.integer :user_id, null: false
      t.timestamps null: false
    end

    add_index :product_platform_associations, %i(product_id platform_id), unique: true, name: 'product_platform_associations_index'
  end
end
