class CreateDigests < ActiveRecord::Migration[5.0]
  def change
    create_table :notification_groups do |t|
      t.integer :kind, null: false
      t.references :user, null: false
      t.timestamps null: false
    end
  end
end
