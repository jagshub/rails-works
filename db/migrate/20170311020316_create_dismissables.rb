class CreateDismissables < ActiveRecord::Migration
  def change
    create_table :dismissables do |t|
      t.string :dismissable_group, null: false
      t.string :dismissable_key, null: false
      t.integer :user_id, null: false
      t.datetime :dismissed_at, null: true

      t.timestamps null: false
    end
  end
end
