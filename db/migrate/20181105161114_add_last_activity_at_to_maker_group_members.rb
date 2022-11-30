class AddLastActivityAtToMakerGroupMembers < ActiveRecord::Migration[5.0]
  def change
    add_column :maker_group_members, :last_activity_at, :datetime, null: true

    add_index :maker_groups, :last_activity_at
    add_index :maker_group_members, :last_activity_at
  end
end
