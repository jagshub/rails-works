class CreateNotificationGroupAssociations < ActiveRecord::Migration[5.0]
  def change
    create_table :notification_group_associations do |t|
      t.references :notification_group, null: false
      t.string :subject_type, null: false
      t.string :subject_id, null: false
      t.timestamps null: false
    end

    add_index :notification_group_associations, [:subject_type, :subject_id, :notification_group_id], unique: true, name: 'index_notif_group_assoc_on_subject_type_and_id_and_group_id'
  end
end
