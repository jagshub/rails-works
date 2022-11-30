class AddMakerGroupMembershipsCountToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :maker_group_memberships_count, :integer, null: false, default: 0
  end
end
