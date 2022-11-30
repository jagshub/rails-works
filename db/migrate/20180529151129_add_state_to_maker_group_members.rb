class AddStateToMakerGroupMembers < ActiveRecord::Migration[5.0]
  def change
    add_column :maker_group_members, :state, :integer, default: 0, null: false
  end
end
