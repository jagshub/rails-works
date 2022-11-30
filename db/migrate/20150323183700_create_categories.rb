class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.text :name, null: false
      t.text :slug, index: :true, null: false
      t.text :description

      t.timestamps null: false
    end
  end
end
