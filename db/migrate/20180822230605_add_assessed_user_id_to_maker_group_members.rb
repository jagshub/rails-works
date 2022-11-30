class AddAssessedUserIdToMakerGroupMembers < ActiveRecord::Migration[5.0]
  def change
    add_column :maker_group_members, :assessed_user_id, :integer, null: true
    add_index :maker_group_members, :assessed_user_id
  end
end
