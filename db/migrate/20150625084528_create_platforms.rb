class CreatePlatforms < ActiveRecord::Migration
  def change
    create_table :platforms do |t|
      t.string :name, null: false
      t.string :icon
      t.string :stores, array: true, default: [], null: false
      t.integer :priority, default: 0, null: false

      t.timestamps null: false
    end

    add_index :platforms, :name, unique: true
  end
end
