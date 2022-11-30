class AddLastActivityAtToMakerGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :maker_groups, :last_activity_at, :datetime, null: true
  end
end
