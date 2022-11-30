class CreateChangeLogMedia < ActiveRecord::Migration[5.1]
  def change
    create_table :change_log_media do |t|
      t.references :change_log_entry, null: false, foreign_key: true, index: true
      t.string :image_uuid, null: false
      t.integer :priority, default: 0, null: false

      t.timestamps
    end
  end
end
