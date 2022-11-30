class CreateCategoriesPlatforms < ActiveRecord::Migration
  def change
    create_table :category_platform_associations do |t|
      t.integer :category_id, null: false
      t.integer :platform_id, null: false
      t.timestamps null: false
    end

    add_index :category_platform_associations, %i(category_id platform_id), unique: true, name: 'category_platform_associations_index'
  end
end
