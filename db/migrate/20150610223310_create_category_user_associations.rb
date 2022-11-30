class CreateCategoryUserAssociations < ActiveRecord::Migration
  def change
    create_table :category_user_associations do |t|
      t.references :category, index: true, null: false
      t.references :user, index: true, null: false

      t.timestamps null: false
    end

    add_index :category_user_associations, [:category_id, :user_id], unique: true
  end
end
