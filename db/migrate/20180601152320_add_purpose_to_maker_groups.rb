class AddPurposeToMakerGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :maker_groups, :purpose, :jsonb
  end
end
