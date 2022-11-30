class AddAssessedAtToMakerGroupMembers < ActiveRecord::Migration[5.0]
  def change
    add_column :maker_group_members, :assessed_at, :datetime, null: true
    add_index :maker_group_members, :assessed_at
  end
end
