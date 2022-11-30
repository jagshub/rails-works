class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :remote_id, null: false
      t.string :name, null: false
      t.monetize :price, null: false
      t.integer :interval, null: false
      t.integer :interval_count, default: 1, null: false
      t.integer :status, null: false
      t.text :description

      t.timestamps null: false
    end
  end
end
