class AddRoleToMakerGroupMembers < ActiveRecord::Migration[5.0]
  def change
    add_column :maker_group_members, :role, :integer, default: 0, null: false

    add_index :maker_group_members, :role
    add_index :maker_group_members, :state
  end
end
